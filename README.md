# Deploy AWS Lambda with Terraform

Usage:

```bash
cd terraform

terraform init
terraform apply
```

Invoke Lambda:

```bash
curl "$(terraform output -raw base_url)/document"
```


### Resources
- https://www.maxivanov.io/deploy-aws-lambda-to-vpc-with-terraform/
- https://developer.hashicorp.com/terraform/tutorials/aws/lambda-api-gateway