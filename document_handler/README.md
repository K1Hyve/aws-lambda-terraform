# document_handler
## Working with this project

This project contains source code and supporting files for a serverless application that you can deploy with the SAM CLI. It includes the following files and folders.

* document_handler - Code for the application's Lambda function.
* template.yaml - A template that defines the application's AWS resources.  

The application uses several AWS resources, including Lambda functions and an API Gateway API. These resources are defined in the `template.yaml` file in this project. You can update the template to add AWS resources through the same deployment process that updates your application code.

### Deploy the sample application

The Serverless Application Model Command Line Interface (SAM CLI) is an extension of the AWS CLI that adds functionality for building and testing Lambda applications. It uses Docker to run your functions in an Amazon Linux environment that matches Lambda. It can also emulate your application's build environment and API.

To use the SAM CLI, you need the following tools.

* SAM CLI - [Install the SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html)
* Docker - [Install Docker community edition](https://hub.docker.com/search/?type=edition&offering=community)

To build and deploy your application for the first time, run the following in your shell:

```bash
sam build
aws ecr create-repository --repository-name document-handler --image-tag-mutability MUTABLE --image-scanning-configuration scanOnPush=false --region eu-west-1
sam package --region eu-west-1 --image-repository <aws-account-id>.dkr.ecr.eu-west-1.amazonaws.com/document-handler
```

```bash
sam delete --region eu-west-1
```