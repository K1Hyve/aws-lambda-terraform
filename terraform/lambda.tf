
resource "aws_lambda_function" "document_handler" {
  code_signing_config_arn = ""
  description             = ""
  function_name           = "${var.project}-lambda-function"
  role                    = aws_iam_role.iam_role.arn
  image_uri               = "${aws_ecr_repository.repo.repository_url}@${data.aws_ecr_image.lambda_image.id}"
  package_type            = "Image"
  kms_key_arn             = aws_kms_key.document_encryption_key.arn

  vpc_config {
    subnet_ids = concat(
      [for i, subnet in var.subnet_private_cidr_block : aws_subnet.subnet_private[i].id],
      [for i, subnet in var.subnet_public_cidr_block : aws_subnet.subnet_public[i].id],
    )
    security_group_ids = [aws_default_security_group.default_security_group.id]
  }

  environment {
    variables = {
      RDS_HOSTNAME   = aws_db_instance.documents.address
      RDS_PORT       = aws_db_instance.documents.port
      RDS_SECRET_ARN = aws_db_instance.documents.master_user_secret[0].secret_arn
      REGION         = var.region
    }
  }

  depends_on = [
    terraform_data.ecr_image
  ]
}

resource "aws_cloudwatch_log_group" "document_handler" {
  name              = "/aws/lambda/${aws_lambda_function.document_handler.function_name}"
  retention_in_days = 30
}
