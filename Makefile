prepare:
	@echo Generate docs
	@terraform-docs markdown table terraform
	@echo Fixing the formatting
	@cd terraform && terraform fmt
	@echo Validating Terraform code
	@cd terraform && terraform validate

build-sam:
	@echo "Building dev environment"
	@cd document_handler && sam build
	@cd document_handler && sam local start-api