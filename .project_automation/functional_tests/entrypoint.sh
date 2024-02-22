#!/bin/bash -e

## NOTE: paths may differ when running in a managed task. To ensure behavior is consistent between
# managed and local tasks always use these variables for the project and project type path
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype

echo "Starting Functional Tests"

cd ${PROJECT_PATH}

#********** TF Env Vars *************
export AWS_DEFAULT_REGION=us-east-1


#********** Checkov Analysis *************
echo "Running Checkov Analysis"
terraform init
terraform plan -out tf.plan
terraform show -json tf.plan  > tf.json
checkov --config-file ${PROJECT_PATH}/.config/.checkov.yml

# #********** Checkov Analysis *************
# echo "Running Checkov Analysis on root module"
# checkov --directory . --skip-path examples --framework terraform

# echo "Running Checkov Analysis on terraform plan"
# terraform init
# terraform plan -out tf.plan
# # terraform plan -out tf.plan -var-file functional_test.tfvars
# terraform show -json tf.plan  > tf.json
# checkov

#********** Terratest execution **********
echo "Running Terratest"
export GOPROXY=https://goproxy.io,direct
cd test
rm -f go.mod
go mod init github.com/aws-ia/terraform-project-ephemeral
go mod tidy
go install github.com/gruntwork-io/terratest/modules/terraform
go test -timeout 45m

echo "End of Functional Tests"


