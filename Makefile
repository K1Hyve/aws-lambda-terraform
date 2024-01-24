build-sam:
	@echo "Building dev environment"
	@cd document_handler && sam build
	@cd document_handler && sam local start-api