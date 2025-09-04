import csv
import boto3
import os
import json
import logging
import io
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    try:
        # Get the file to process form event
        file_name = event.get('file')

        # Get bucket name from environment
        bucket_name = os.environ.get('DATASETS_BUCKET')

        # Read CSV from S3
        csv_content = read_csv_from_s3(bucket_name, file_name)
        reader = csv.DictReader(io.StringIO(csv_content))
        rows = list(reader)
        logger.info(f"Parsed {len(rows)} rows from CSV")
        logger.info(f"First row: {rows[0] if rows else 'No data'}")

        if file_name == 'hotels.csv':
            table_name = os.environ.get('HOTELS_TABLE')
            logger.info(f"Will write to table: {table_name}")
            dynamodb = boto3.client('dynamodb')

            # Process rows in batches of 25
            batch_size = 25
            total_written = 0

            for i in range(0, len(rows), batch_size):
                batch = rows[i:i + batch_size]

                # Create batch request
                request_items = {
                    table_name: [
                        {
                            'PutRequest': {
                                'Item': {
                                    'hotel_id': {'S': row['hotel_id']},
                                    'hotel_name': {'S': row['hotel_name']},
                                    'city_id': {'S': row['city_id']},
                                    'rating': {'N': row['rating']},
                                    'price_band': {'S': row['price_band']},
                                    'tags': {'S': row['tags']},
                                    'popularity_score': {'N': row['popularity_score']}
                                }
                            }
                        }
                        # Creates one PutRequest per row
                        for row in batch 
                    ]
                }

                # Write batch to DynamoDB
                response = dynamodb.batch_write_item(RequestItems=request_items)
                total_written += len(batch)
                logger.info(f"Wrote batch of {len(batch)} items. Total: {total_written}")
            
            logger.info(f"Successfully wrote all {total_written} hotels to DynamoDB")   
        elif file_name == 'user_interactions.csv':
            table_name = os.environ.get('USER_INTERACTIONS_TABLE')
            logger.info(f"Will write to table: {table_name}")
            dynamodb = boto3.client('dynamodb')
            
            # Process rows in batches of 25
            batch_size = 25
            total_written = 0
            
            for i in range(0, len(rows), batch_size):
                batch = rows[i:i + batch_size]
                
                request_items = {
                    table_name: [
                        {
                            'PutRequest': {
                                'Item': {
                                    'user_id': {'S': row['user_id']},
                                    'interaction_id': {'S': row['interaction_id']},
                                    'hotel_id': {'S': row['hotel_id']},
                                    'interaction_type': {'S': row['interaction_type']},
                                    'timestamp': {'S': row['timestamp']},
                                    'session_id': {'S': row['session_id']}
                                }
                            }
                        }
                        for row in batch
                    ]
                }
                
                response = dynamodb.batch_write_item(RequestItems=request_items)
                total_written += len(batch)
                logger.info(f"Wrote batch of {len(batch)} interactions. Total: {total_written}")
            
            logger.info(f"Successfully wrote all {total_written} interactions to DynamoDB")

        else:
            logger.info(f"No processing logic for {file_name} yet")
    
        # For now, just log the first 100 characters to verify it worked
        logger.info(f"Successfully read {len(csv_content)} characters from {file_name}")
        logger.info(f"First 100 chars: {csv_content[:100]}")

        return {
            'statusCode': 200,
            'body': json.dumps({'message': f'Successfully processed {file_name}'})
        }
    
    except Exception as e:
        logger.error(f'Error processing file: {str(e)}')
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
    
def read_csv_from_s3(bucket_name, file_key):
    try:
        s3 = boto3.client('s3')
        response = s3.get_object(Bucket=bucket_name, Key=file_key)
        csv_content = response['Body'].read().decode('utf-8')
        return csv_content

    except ClientError as e:
        error_code = e.response['Error']['Code']
        if error_code == 'NoSuchKey':
            logger.error(f"File not found: {file_key} in bucket {bucket_name}")
            raise Exception(f"File not found: {file_key}")
        elif error_code == 'AccessDenied':
            logger.error(f"Access denied for {file_key} in bucket {bucket_name}")
            raise Exception(f"Access denied: {file_key}")
        else:
            logger.error(f"S3 error reading {file_key}: {str(e)}")
            raise Exception(f"S3 error: {str(e)}")
        
    except Exception as e:
        logger.error(f"Unexpected error reading {file_key}: {str(e)}")
        raise Exception(f"Unexpected error: {str(e)}")
