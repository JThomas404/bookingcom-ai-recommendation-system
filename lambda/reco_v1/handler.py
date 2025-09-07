import boto3
import os
import json
import logging
from decimal import Decimal
from boto3.dynamodb.types import TypeDeserializer

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Custom JSON encoder for Decimal objects
class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)

def lambda_handler(event, context):
    # City ID to name mapping
    CITY_NAMES = {
        'CITY_001': 'London',
        'CITY_002': 'Paris', 
        'CITY_003': 'New York',
        'CITY_004': 'Tokyo',
        'CITY_005': 'Barcelona',
        'CITY_006': 'Amsterdam',
        'CITY_007': 'Rome',
        'CITY_008': 'Berlin',
        'CITY_009': 'Prague',
        'CITY_010': 'Vienna'
    }
    
    # Initialise the DynamoDB client connection
    dynamodb = boto3.client('dynamodb')

    # Extract query parameters
    params = event.get("queryStringParameters") or {}
    city_input = params.get('city_id') or params.get('city')
    
    # Handle both city names and city IDs
    if city_input in CITY_NAMES:
        city_id = city_input
        city_name = CITY_NAMES[city_id]
    else:
        # Try to find city ID by name
        city_id = None
        city_name = city_input
        for cid, cname in CITY_NAMES.items():
            if cname.lower() == city_input.lower():
                city_id = cid
                city_name = cname
                break
    try:
        # Validate city_id
        if not city_id:
            return {
                'statusCode': 400,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type',
                    'Access-Control-Allow-Methods': 'GET,OPTIONS'
                },
                'body': json.dumps({'error': 'city_id is required'})
                }
        # Convert and validate limit
        try:
            limit = int(params.get('limit', 10))
            if limit <= 0:
                return {'statusCode': 400, 'body': json.dumps({'error': 'limit must be a positive number'})}
        except ValueError:
            return {'statusCode': 400, 'body': json.dumps({'error': 'limit must be a valid number'})}
        
        user_tags = [t.strip() for t in params.get('user_tags', '').split(",") if t.strip()]

    except Exception as e:
        logger.error(f'Unexpected error in parameter processing: {str(e)}')
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'GET,OPTIONS'
            },
            'body': json.dumps({'error': 'Internal server error'})
        }        

    table_name = os.environ.get('HOTELS_TABLE')
    if not table_name:
        logger.error('HOTELS_TABLE environment variable not set')
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'GET,OPTIONS'
            },
            'body': json.dumps({'error': 'Service configuration error'})
        }
    try:
        # Scan DynamoDB table with city filter
        response = dynamodb.scan(
            TableName=table_name,
            FilterExpression='#city_id = :city_value',
            ExpressionAttributeNames={'#city_id':'city_id'},
            ExpressionAttributeValues={':city_value': {'S':city_id}}
        )
    except Exception as e:
        logger.error(f'Error querying DynamoDB: {str(e)}')
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'GET,OPTIONS'
            },
            'body': json.dumps({'error': str(e)})
        }  

    # Extract hotels from DynamoDB response
    items = response.get('Items', [])
    if not items:
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'GET,OPTIONS'
            },
            'body': json.dumps({
                'city': city_name,
                'city_id': city_id,
                'hotels': [],
                'count': 0,
                'message': 'No hotels found in this city'
                })
            }
    # Convert DynamoDB format to Python Dictionaries
    deserializer = TypeDeserializer()
    hotels = []
    for item in items:
        hotel = {k: deserializer.deserialize(v) for k, v in item.items()}
        hotels.append(hotel)

    # Calculate scoring for each hotel
    for hotel in hotels:
        # Extract hotel data with safe defaults and convert Decimals to float
        rating = float(hotel.get('rating', 0))
        popularity = float(hotel.get('popularity_score', 0))
        hotel_tags = hotel.get('tags', '')
        
        # Convert all Decimal values to float for JSON serialization
        for key, value in hotel.items():
            if isinstance(value, Decimal):
                hotel[key] = float(value)
        
        # Calculate each scoring component  
        normalised_rating = (rating - 1) / 4
        
        # Calculate tag overlap
        if user_tags:
            hotel_tag_list = [tag.strip() for tag in hotel_tags.split(',') if tag.strip()]
            matches = sum(1 for tag in user_tags if tag in hotel_tag_list)
            tag_overlap_percentage = (matches / len(user_tags)) * 100
        else:
            tag_overlap_percentage = 100
        
        # Apply V1 formula
        score = 0.5 * popularity + 0.3 * normalised_rating + 0.2 * (tag_overlap_percentage / 100)
        
        # Add score to hotel dictionary
        hotel['recommendation_score'] = round(score, 4)

    # Sort hotels by recommendation score (highest first)
    hotels.sort(key=lambda h: h['recommendation_score'], reverse=True)

    # Apply limit parameter
    hotels = hotels[:limit]

    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Methods': 'GET,OPTIONS'
        },
        'body': json.dumps({
            'city': city_name,
            'city_id': city_id,
            'hotels': hotels,
            'count': len(hotels)
        }, cls=DecimalEncoder)
    }

