import json

def lambda_handler(event, context):
    if event.get('path') == '/health':
        return {
            'statusCode': 200,
            'body': json.dumps({'status': 'healthy'})
        }
    
    return {
        'statusCode': 404,
        'body': json.dumps({'error': 'Not found'})
    }
