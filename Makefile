SHELL_SPEC_DIR ?= /var/tmp
TERRAFORM_VAR_FILE = terraform.tfvars

.DEFAULT_GOAL := help

.PHONY: help
help:
	@grep -h -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: apply 
apply: ## Applies Terraform plan
	@test -s $(TERRAFORM_VAR_FILE) || { echo "The 'apply' rule assumes that variables are provided $(TERRAFORM_VAR_FILE)"; exit 1; }
	terraform apply -auto-approve --var-file $(TERRAFORM_VAR_FILE)

.PHONY: destroy 
destroy: ## Destroys Terraform infrastructure
	terraform destroy -auto-approve --var-file $(TERRAFORM_VAR_FILE)

.PHONY: plan
plan: ## Outputs the Terraform plan
	terraform plan --var-file $(TERRAFORM_VAR_FILE)	-no-color

.PHONY: init 
init: ## Init the terraform module
	terraform init

.PHONY: lint 
lint: init ## Verifies Terraform syntax
	terraform version
	terraform fmt -check -diff
	terraform validate

.PHONY: fmt
fmt: ## Reformats Terraform files accoring to standard
	terraform fmt

.PHONY: test 
test: ## Runs ShellSpec tests
	shellspec --format document	

.PHONY: test-focus 
test-focus: ## Runs focused ShellSpec tests
	shellspec --focus --format document		

.PHONY: clean
clean: ## Deletes temporary files
	rm -rf report
	rm jx-requirements.yml
			