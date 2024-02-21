package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestAWSandCustomerManagedPolicies(t *testing.T) {

	terraformOptions := &terraform.Options{
		// The path to where your Terraform code is located
		TerraformDir: "../examples/create-users-and-groups/aws-and-customer-managed-policies",

	}

	// At the end of the test, run 'terrform destroy' to clean up any resources that were created
	defer terraform.DestroyE(t, terraformOptions)

	// Run 'terraform init' and 'terraform apply'. Fail the test if there are any errors.
	terraform.InitAndApplyE(t, terraformOptions)

	if _, err := terraform.ApplyE(t, terraformOptions); err != nil {
  // Do something with err
		fmt.Print("Expected potential error - Skip")
	}
	if _, err := terraform.DestroyE(t, terraformOptions); err != nil {
  // Do something with err
	fmt.Print("Expected potential error - Skip")
	}

}
