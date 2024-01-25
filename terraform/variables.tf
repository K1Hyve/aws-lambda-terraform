variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment (dev / stage / prod)"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "profile" {
  type        = string
  description = "AWS Profile"
  default     = "default"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR"
}

variable "subnet_private_cidr_block" {
  description = "List of private subnet configurations"
  type        = list(any)
}

variable "subnet_public_cidr_block" {
  description = "List of public subnet configurations"
  type        = list(any)
}

variable "nat_subnet" {
  description = "Subnet for NAT gateway"
  type        = string
}

variable "rds_identifier" {
  type        = string
  description = "Identifier of the RDS database"
}

variable "rds_username" {
  type        = string
  description = "Username of the RDS instance"
}

variable "rds_instance_class" {
  type        = string
  description = "Class of the RDS instance"
}

variable "rds_allocated_storage" {
  type        = string
  description = "Allocated storage of the RDS instance"
}

variable "s3_bucket_prefix" {
  type        = string
  description = "Prefix of the S3 bucket"
}

