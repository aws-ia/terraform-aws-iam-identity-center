package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestGoogleWorkspace(t *testing.T) {

	terraformOptions := &terraform.Options{
		// The path to where your Terraform code is located
		TerraformDir: "../examples/google-workspace",

	}

	// At the end of the test, run 'terraform destroy' to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// Run 'terraform init' and 'terraform apply'. Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

}
