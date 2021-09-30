export AWS_PAGER=""

CFN_FILE = 

.PHONY: build
all: permissions
	$(MAKE) bootstrap-region AWS_REGION=us-east-1
	$(MAKE) bootstrap-region AWS_REGION=us-east-2
	$(MAKE) bootstrap-region AWS_REGION=us-west-1
	$(MAKE) bootstrap-region AWS_REGION=us-west-2

.PHONY: permissions
permissions:
	cfn-lint -t permissions.yaml
	aws cloudformation validate-template --template-body file://permissions.yaml
	aws cloudformation deploy \
		--template-file permissions.yaml \
		--stack-name stackset-permissions-$$(aws sts get-caller-identity --query Arn --output text | sed 's/.*\///g') \
		--parameter-overrides \
			UserArn=$$(aws sts get-caller-identity --query Arn --output text)  \
			UserName=$$(aws sts get-caller-identity --query Arn --output text | sed 's/.*\///g')  \
		--capabilities CAPABILITY_NAMED_IAM

.PHONY: bootstrap-region
bootstrap-region:
	@[ -n $(AWS_REGION) ] || (echo "You must manually set the AWS_REGION" && exit 1)
	AWS_REGION=$(AWS_REGION) aws cloudformation deploy \
		--template-file terraform-cloudformation.yaml \
		--stack-name terraform-bootstrap-$(AWS_REGION)

# .PHONY: bootstrap
# bootstrap:
# 	cfn-lint -t terraform-cloudformation.yaml
# 	aws cloudformation validate-template --template-body file://terraform-cloudformation.yaml
# 	aws cloudformation deploy \
# 		--template-file terraform-cloudformation.yaml \
# 		--stack-name terraform-bootstrap

# .PHONY:
# deploy:
# 	@[ -n $(CFN_FILE) ] || (echo "You must set CFN_FILE to be deployed." && exit 1)
# 	cfn-lint -t $(CFN_FILE)
# 	aws cloudformation validate-template --template-body file://$(CFN_FILE)
# 	aws cloudformation deploy --template-file $(CFN_FILE) --stack-name terraform_bootstrap_$(basename $(CFN_FILE)) 