# Fetch Account Id from SSM Parameter Store
data "aws_ssm_parameter" "account1_account_id" {
  name = "tf-aws-iam-idc-module-testing-account1-account-id" // replace with your SSM Parameter Key
}

locals {
  # Account IDs
  account1_account_id = nonsensitive(data.aws_ssm_parameter.account1_account_id.value)
  # account1_account_id = "111111111111"
  # account2_account_id = "222222222222"
  # account3_account_id = "333333333333"
  # account4_account_id = "444444444444"

}
