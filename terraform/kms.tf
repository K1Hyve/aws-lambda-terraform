resource "aws_kms_key" "document_encryption_key" {
  description             = "Encrypt RDS and S3 bucket"
  deletion_window_in_days = 10
}
