def document_handler(event, context):
    return {
        'statusCode': 200,
        'body': 'Hello from Lambda!'
    }