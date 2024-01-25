resource "aws_db_subnet_group" "documents" {
  name       = "documents"
  subnet_ids = [for i, subnet in var.subnet_private_cidr_block : aws_subnet.subnet_private[i].id]
}

resource "aws_db_instance" "documents" {
  allocated_storage               = var.rds_allocated_storage
  allow_major_version_upgrade     = true
  apply_immediately               = true
  auto_minor_version_upgrade      = true
  db_subnet_group_name            = aws_db_subnet_group.documents.name
  delete_automated_backups        = true
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  engine                          = "mysql"
  engine_version                  = var.rds_database_version
  identifier                      = var.rds_identifier
  instance_class                  = var.rds_instance_class
  kms_key_id                      = aws_kms_key.document_encryption_key.arn
  maintenance_window              = "Tue:02:00-Tue:05:00"
  manage_master_user_password     = "true"
  master_user_secret_kms_key_id   = aws_kms_key.document_encryption_key.arn
  monitoring_interval             = "0"   # Todo: Enable
  multi_az                        = false # Money!
  performance_insights_enabled    = false # Todo: Enable
  # performance_insights_kms_key_id       = aws_kms_key.document_encryption_key.arn
  # performance_insights_retention_period = "7"
  publicly_accessible    = false
  skip_final_snapshot    = true
  storage_encrypted      = true
  storage_type           = "gp2"
  username               = var.rds_username
  vpc_security_group_ids = [aws_default_security_group.default_security_group.id]
}
