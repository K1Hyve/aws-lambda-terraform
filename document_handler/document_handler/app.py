import hashlib

import pymysql
import boto3

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

@app.get("/document/<document_id>")
@tracer.capture_method
def get_document(document_id: str):
    ssm_client = boto3.client('ssm')
    rds_client = boto3.client('rds')

    # adding custom metrics
    # See:  https://awslabs.github.io/aws-lambda-powertools-python/latest/core/metrics/
    metrics.add_metric(name="GetDocumentInvocations", unit=MetricUnit.Count, value=1)

    # structured log
    # See: https://awslabs.github.io/aws-lambda-powertools-python/latest/core/logger/
    logger.info("GetDocument - HTTP 200")

    return {"message": "Serving document {}".format(document_id)}

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
