
data "aws_iam_policy_document" "AWSLambdaTrustPolicy" {
  version = "2012-10-17"

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "get_rds_secretsmanager_secrets" {
  version = "2012-10-17"

  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    effect    = "Allow"
    resources = [aws_db_instance.documents.master_user_secret[0].secret_arn]
  }
}

resource "aws_iam_policy" "get_rds_secretsmanager_secrets" {
  name   = "get_rds_secretsmanager_secrets"
  policy = data.aws_iam_policy_document.get_rds_secretsmanager_secrets.json
}

resource "aws_iam_role" "iam_role" {
  assume_role_policy = data.aws_iam_policy_document.AWSLambdaTrustPolicy.json
  name               = "${var.project}-iam-role-lambda-trigger"
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_lambda_basic_execution" {
  role       = aws_iam_role.iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment_lambda_vpc_access_execution" {
  role       = aws_iam_role.iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_secretsmanager_role" {
  role       = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.get_rds_secretsmanager_secrets.arn
}
