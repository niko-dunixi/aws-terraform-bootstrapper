export AWS_PAGER=""

.PHONY: build
build:
	cfn-lint -t cloudformation.yaml
	aws cloudformation validate-template --template-body file://cloudformation.yaml
	aws cloudformation deploy --template-file cloudformation.yaml --stack-name terraform-bootstrapper 
