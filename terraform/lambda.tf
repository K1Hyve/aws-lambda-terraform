data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "../lambda"
  output_path = "lambda.zip"
}


resource "aws_lambda_function" "document_handler" {
  code_signing_config_arn = ""
  description             = ""
  filename                = data.archive_file.lambda.output_path
  function_name           = "${var.project}-lambda-function"
  role                    = aws_iam_role.iam_role.arn
  handler                 = "app.document_handler"
  runtime                 = "python3.12"
  source_code_hash        = filebase64sha256(data.archive_file.lambda.output_path)
  vpc_config {
    subnet_ids         = [aws_subnet.subnet_public.id, aws_subnet.subnet_private.id]
    security_group_ids = [aws_default_security_group.default_security_group.id]
  }
}

resource "aws_cloudwatch_log_group" "document_handler" {
  name = "/aws/lambda/${aws_lambda_function.document_handler.function_name}"

  retention_in_days = 30
}