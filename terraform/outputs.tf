# output "lambda_function_arn" {
#   value       = aws_lambda_function.document_handler.arn
#   description = "Lambda ARN"
# }

output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.documents.address
  sensitive   = false
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.documents.port
  sensitive   = false
}

output "rds_password_secret_arn" {
  description = "RDS password secret ARN"
  value       = aws_db_instance.documents.master_user_secret[0].secret_arn
  sensitive   = false
}

output "rds_password_kms_key_id" {
  description = "RDS password KMS ID"
  value       = aws_db_instance.documents.master_user_secret[0].kms_key_id
  sensitive   = false
}

output "base_url" {
  description = "Base URL for API Gateway stage."
  value       = aws_apigatewayv2_stage.document_handler.invoke_url
}
