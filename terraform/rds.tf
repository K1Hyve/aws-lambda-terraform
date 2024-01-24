resource "aws_db_subnet_group" "documents" {
  name       = "documents"
  subnet_ids = [aws_subnet.subnet_private.id]

  tags = {
    Name = "Documents"
  }
}

resource "aws_db_instance" "documents" {
  identifier             = "documents"
  instance_class         = "db.t4g.micro"
  allocated_storage      = 5
  engine                 = "mysql"
  engine_version         = "8"
  username               = "documents"
  manage_master_user_password = "true"
  db_subnet_group_name   = aws_db_subnet_group.documents.name
  vpc_security_group_ids = [aws_default_security_group.default_security_group.id]

  publicly_accessible    = false
  skip_final_snapshot    = true  
  allow_major_version_upgrade = true
  auto_minor_version_upgrade = true
  delete_automated_backups = true
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  maintenance_window = "Tue:02:00-Tue:05:00"
  monitoring_interval = "10"
  multi_az = false # Money!
  performance_insights_enabled = true
  performance_insights_retention_period = "7"
  storage_encrypted = true
  storage_type = "gp2"
  apply_immediately = true
}