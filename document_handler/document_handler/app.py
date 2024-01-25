import hashlib
import os

import pymysql
import pymysql.cursors
import boto3
from botocore.exceptions import ClientError

from aws_lambda_powertools.event_handler import APIGatewayHttpResolver
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws_lambda_powertools.logging import correlation_paths
from aws_lambda_powertools import Logger
from aws_lambda_powertools import Tracer
from aws_lambda_powertools import Metrics
from aws_lambda_powertools.metrics import MetricUnit

app = APIGatewayHttpResolver()
tracer = Tracer()
logger = Logger()
metrics = Metrics(namespace="Powertools")

def get_secret():
    secret_id = os.environ.get('RDS_SECRET_ARN', None)
    region_name = os.environ.get('REGION', None)

    if not (secret_id and region_name):
        return None

    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name,
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_id
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'ResourceNotFoundException':
            logger.info("The requested secret " + secret_id + " was not found")
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            logger.info("The request was invalid due to:", e)
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            logger.info("The request had invalid params:", e)
        elif e.response['Error']['Code'] == 'DecryptionFailure':
            logger.info("The requested secret can't be decrypted using the provided KMS key:", e)
        elif e.response['Error']['Code'] == 'InternalServiceError':
            logger.info("An error occurred on service side:", e)
    else:
        # Secrets Manager decrypts the secret value using the associated KMS CMK
        # Depending on whether the secret was a string or binary, only one of these fields will be populated
        if 'SecretString' in get_secret_value_response:
            return get_secret_value_response['SecretString']
        else:
            return get_secret_value_response['SecretBinary']

def mysqlconnect():
    logger.info("Getting DB creds")
    creds = get_secret()
    # To connect MySQL database
    logger.info("Connecting to the DB")
    conn = pymysql.connect(
        host=os.environ.get('RDS_HOSTNAME', None),
        user=creds['USERNAME'],
        password=creds['PASSWORD'],
    )

    cur = conn.cursor()
    logger.info("Running DB query")
    cur.execute("select @@version")
    output = cur.fetchall()

    # To close the connection
    conn.close()

    return output

@app.get("/document/<document_id>")
@tracer.capture_method
def get_document(document_id: str):
    s3_client = boto3.client('s3')

    # logger.info("Get DB Status")
    # db_status = mysqlconnect() # get_secret() doesn't respond after 15 seconds

    # adding custom metrics
    # See:  https://awslabs.github.io/aws-lambda-powertools-python/latest/core/metrics/
    metrics.add_metric(name="GetDocumentInvocations", unit=MetricUnit.Count, value=1)

    # structured log
    # See: https://awslabs.github.io/aws-lambda-powertools-python/latest/core/logger/
    logger.info("GetDocument - HTTP 200")

    return {
        "message": "Serving document {}".format(document_id),
        "database": "Database response: {}".format(db_status)
        }

@app.post("/document")
@tracer.capture_method
def post_document():
    # adding custom metrics
    # See: https://awslabs.github.io/aws-lambda-powertools-python/latest/core/metrics/
    metrics.add_metric(name="PostDocumentInvocations", unit=MetricUnit.Count, value=1)

    # structured log
    # See: https://awslabs.github.io/aws-lambda-powertools-python/latest/core/logger/
    logger.info("PostDocumen - HTTP 200")

    document_id = hashlib.sha256(app.current_event.body.encode()).hexdigest()
    return {
        'message': "Upload successful! Referrence: {}".format(document_id)
    }

# Enrich logging with contextual information from Lambda
@logger.inject_lambda_context(correlation_id_path=correlation_paths.API_GATEWAY_HTTP)
# Adding tracer
# See: https://awslabs.github.io/aws-lambda-powertools-python/latest/core/tracer/
@tracer.capture_lambda_handler
# ensures metrics are flushed upon request completion/failure and capturing ColdStart metric
@metrics.log_metrics(capture_cold_start_metric=True)
def lambda_handler(event: dict, context: LambdaContext) -> dict:
    return app.resolve(event, context)
