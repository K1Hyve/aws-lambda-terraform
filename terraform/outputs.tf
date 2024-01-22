output "lambda_function_arn" {
  value       = aws_lambda_function.document_handler.arn
  description = "Lambda ARN"
}

output "base_url" {
  description = "Base URL for API Gateway stage."

  value = aws_apigatewayv2_stage.document_handler.invoke_url
}