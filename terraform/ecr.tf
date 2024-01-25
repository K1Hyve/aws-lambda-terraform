data "aws_caller_identity" "current" {}

locals {
  prefix              = "git"
  account_id          = data.aws_caller_identity.current.account_id
  ecr_repository_name = "document-handler"
  ecr_image_tag       = "latest"
}

resource "aws_ecr_repository" "repo" {
  name                 = local.ecr_repository_name
  image_tag_mutability = "MUTABLE"
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "terraform_data" "ecr_image" {
  triggers_replace = [
    timestamp(), # this will always run, in case of bad internet
    md5(file("../${path.module}/document_handler/document_handler/app.py")),
    md5(file("../${path.module}/document_handler/document_handler/Dockerfile"))
  ]

  # The sam package gives a random tag to the docker image and makes it difficult to reference it later in Terraform
  # sam build && sam package --region ${var.region} --image-repository ${aws_ecr_repository.repo.repository_url}
  provisioner "local-exec" {
    working_dir = "../document_handler/"
    command     = <<EOF
            aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com && cd document_handler &&  docker build -t ${aws_ecr_repository.repo.repository_url}:${local.ecr_image_tag} . && docker push ${aws_ecr_repository.repo.repository_url}:${local.ecr_image_tag}
        EOF
  }
}

data "aws_ecr_image" "lambda_image" {
  depends_on = [
    terraform_data.ecr_image
  ]

  repository_name = local.ecr_repository_name
  image_tag       = local.ecr_image_tag
}
