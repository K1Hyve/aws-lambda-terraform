provider "aws" {
  region  = var.region
  profile = var.profile

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      Name        = var.project
    }
  }
}

locals {
  azs = ["${var.region}a", "${var.region}b", "${var.region}c"]
}
