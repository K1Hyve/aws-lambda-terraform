# Terraform AWS Infrastructure Setup

Deployment for a AWS Lambda Document API function that uses a MySQL backend for database persistence and S3 for the storage of small PDF files. It will be exposed using API gateway. The Lambda function can be developed using AWS SAM and Docker used for packaging the Lambda function. Credentials are securely managed with AWS Secrets Manager.

## Configuration Files

`terraform.tfvars` Provides values for the defined variables.

## Deployment Steps

1. **Initialize Terraform"**
   Navigate to the directory containing your Terraform files and run the following command to initialize Terraform: `terraform init`
2. **Review the Plan:**
   To see the changes Terraform will make, execute: `terraform plan`
3. **Apply the Configuration:**
   To create the resources in AWS, run: `terraform apply --auto-approve`
4. **Invoke Lambda:**
   Run following command to test the Lambda function: `curl "$(terraform output -raw base_url)/document/11"`

### To do
- Simple integration between the Lambda and S3 & RDS
- Look into simple authentication for Lambda function
- Look into ad-hoc testablity

### Known issues
- Using Terraform to build and push images. This should be handled by a CI job on push, Terraform is the wrong tool for the job.
- Lambda function lacks authentications

### Resources
- https://www.maxivanov.io/deploy-aws-lambda-to-vpc-with-terraform/
- https://developer.hashicorp.com/terraform/tutorials/aws/lambda-api-gateway
