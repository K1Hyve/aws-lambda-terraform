
resource "aws_lambda_function" "document_handler" {
  code_signing_config_arn = ""
  description             = ""
  function_name           = "${var.project}-lambda-function"
  role                    = aws_iam_role.iam_role.arn
  image_uri               = "${aws_ecr_repository.repo.repository_url}@${data.aws_ecr_image.lambda_image.id}"
  package_type            = "Image"
  vpc_config {
    subnet_ids         = [aws_subnet.subnet_public.id, aws_subnet.subnet_private.id]
    security_group_ids = [aws_default_security_group.default_security_group.id]
  }
  depends_on = [
   terraform_data.ecr_image
 ]
}

resource "aws_cloudwatch_log_group" "document_handler" {
  name = "/aws/lambda/${aws_lambda_function.document_handler.function_name}"

  retention_in_days = 30
}