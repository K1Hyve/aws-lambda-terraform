# Define a name for the API Gateway and set its protocol to HTTP
resource "aws_apigatewayv2_api" "document_handler" {
  name          = "document_handler_gw"
  protocol_type = "HTTP"
}

# Set up application stages for the API Gateway with access logging enabled.
resource "aws_apigatewayv2_stage" "document_handler" {
  api_id = aws_apigatewayv2_api.document_handler.id

  name        = "document_handler_${var.environment}_stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

# Configures the API Gateway to use the document_handler Lambda function.
resource "aws_apigatewayv2_integration" "document_handler" {
  api_id = aws_apigatewayv2_api.document_handler.id

  integration_uri    = aws_lambda_function.document_handler.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

# Map an HTTP request to the Lambda function. 
# The route_key matches any GET request matching the path /document/{document_id}
# A target matching integrations/<ID> maps to a Lambda integration with the given ID.
resource "aws_apigatewayv2_route" "get_document" {
  api_id = aws_apigatewayv2_api.document_handler.id

  authorization_type = "NONE"
  route_key          = "GET /document/{document_id}"
  target             = "integrations/${aws_apigatewayv2_integration.document_handler.id}"
}

resource "aws_apigatewayv2_route" "post_document" {
  api_id = aws_apigatewayv2_api.document_handler.id

  authorization_type = "NONE"
  route_key          = "POST /document"
  target             = "integrations/${aws_apigatewayv2_integration.document_handler.id}"
}

# Define a log group to store access logs for the aws_apigatewayv2_stage.document_handler API Gateway stage.
resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.document_handler.name}"

  retention_in_days = 30
}

# Gives API Gateway permission to invoke the Lambda function.
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.document_handler.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.document_handler.execution_arn}/*/*"
}