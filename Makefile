export AWS_PAGER=""

CFN_FILE = 

.PHONY: build
all: permissions

.PHONY: permissions
permissions:
	cfn-lint -t permissions.yaml
	aws cloudformation validate-template --template-body file://permissions.yaml
	aws cloudformation deploy \
		--template-file permissions.yaml \
		--stack-name stackset-permissions \
		--parameter-overrides MyUserArn=$$(aws sts get-caller-identity --query Arn --output text) \
		--capabilities CAPABILITY_NAMED_IAM

# .PHONY:
# deploy:
# 	@[ -n $(CFN_FILE) ] || (echo "You must set CFN_FILE to be deployed." && exit 1)
# 	cfn-lint -t $(CFN_FILE)
# 	aws cloudformation validate-template --template-body file://$(CFN_FILE)
# 	aws cloudformation deploy --template-file $(CFN_FILE) --stack-name terraform_bootstrap_$(basename $(CFN_FILE)) 