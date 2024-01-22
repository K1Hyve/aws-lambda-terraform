import hashlib
# import json

# def document_handler(event, context):
#     return {
#         'statusCode': 200,
#         'body': json.dumps(event)
#     }

def document_handler(event, context):
    if event["httpMethod"] == "GET":
        return get_document(event["pathParameters"]["document_id"])
    elif event["httpMethod"] == "POST":
        return post_document(event["body"])
    else:
        return {
            'statusCode': 400,
            'body': "Invalid request"
        }

def get_document(document_id):
    if document_id:
        return {
            'statusCode': 200,
            'body': "Serving document {}".format(document_id)
        }
    else:
        return {
            'statusCode': 404,
            'body': "Please provide a document ID"
        }

def post_document(data):
    document_id = hashlib.sha256(data.encode()).hexdigest()
    return {
            'statusCode': 200,
            'body': "Uploaded successful! Referrence: {}".format(document_id)
        }