# Deploy AWS Lambda with Terraform

Usage:

```bash
cd terraform

terraform init
terraform apply
```

Invoke Lambda:

```bash
curl "$(terraform output -raw base_url)/document/11"
```

### To do
- Add S3
- Add RDS
- Simple integration between the Lambda and S3 & RDS
- Check out SSM
- Look into simple authentication for Lambda function
- Fix deprecation warrning in AWS EIP
- Look into ad-hoc testablity

### Known issues
- Using Terraform to build and push images. This should be handled by a CI job on push, Terraform is the wrong tool for the job.
- Lambda function lacks authentications

### Resources
- https://www.maxivanov.io/deploy-aws-lambda-to-vpc-with-terraform/
- https://developer.hashicorp.com/terraform/tutorials/aws/lambda-api-gateway