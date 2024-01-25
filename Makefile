.PHONY: gen
gen: gen-chart-doc

.PHONY: gen-chart-doc
gen-chart-doc:
	@echo "Generate docs"
	@terraform-docs markdown table terraform

build-sam:
	@echo "Building dev environment"
	@cd document_handler && sam build
	@cd document_handler && sam local start-api