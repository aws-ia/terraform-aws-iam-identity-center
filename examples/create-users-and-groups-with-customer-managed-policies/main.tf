# Create a customer-managed policy
# NOTE: In this example we are using a customer managed policy called MyTestCustomerPolicy, this policy must exist in the account before running the terraform scripts


module "aws-iam-identity-center" {
  source = "../.." // local example
  # source = "aws-ia/iam-identity-center/aws" // remote example

  // Create desired GROUPS in IAM Identity Center
  sso_groups = {
    Admin : {
      group_name        = "Admin"
      group_description = "Admin IAM Identity Center Group"
    },
    Dev : {
      group_name        = "Dev"
      group_description = "Dev IAM Identity Center Group"
    },
    QA : {
      group_name        = "QA"
      group_description = "QA IAM Identity Center Group"
    },
    Audit : {
      group_name        = "Audit"
      group_description = "Audit IAM Identity Center Group"
    },
  }

  // Create desired USERS in IAM Identity Center
  sso_users = {
    nuzumaki : {
      group_membership = ["Admin", "Dev", "QA", "Audit", ]
      user_name        = "nuzumaki"
      given_name       = "Naruto"
      family_name      = "Uzumaki"
      email            = "nuzumaki@hiddenleaf.village"
    },
    suchiha : {
      group_membership = ["QA", "Audit"]
      user_name        = "suchiha"
      given_name       = "Sasuke"
      family_name      = "Uchiha"
      email            = "suchiha@hiddenleaf.village"
    },
  }

  // Create permissions sets backed by AWS managed policies
  permission_sets = {
    AdministratorAccess = {
      description          = "Provides AWS full access permissions.",
      session_duration     = "PT4H", // how long until session expires - this means 4 hours. max is 12 hours
      aws_managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
      tags                 = { ManagedBy = "Terraform" }
    },
    # Permission set with customer-managed policies
    S3ReadOnlyAccess = {
      description              = "Provides S3 read-only access using a customer-managed policy."
      session_duration         = "PT2H" // 2 hours
      customer_managed_policies = ["MyTestCustomerPolicy"] // pass the customer managed policy
      tags                     = { ManagedBy = "Terraform" }
    },
    # Permission set with both AWS managed and customer-managed policies
    HybridAccess = {
      description              = "Provides a mix of AWS managed and customer-managed policies."
      session_duration         = "PT2H" // 2 hours
      aws_managed_policies     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
      customer_managed_policies = ["MyTestCustomerPolicy"] // pass the customer managed policy
      tags                     = { ManagedBy = "Terraform" }
    },
  }

  // Assign users/groups access to accounts with the specified permissions
  account_assignments = {
    Admin : {
      principal_name  = "Admin"                                   # name of the user or group you wish to have access to the account(s)
      principal_type  = "GROUP"                                   # entity type (user or group) you wish to have access to the account(s). Valid values are "USER" or "GROUP"
      principal_idp   = "INTERNAL"                                # type of Identity Provider you are using. Valid values are "INTERNAL" (using Identity Store) or "EXTERNAL" (using external IdP such as EntraID, Okta, Google, etc.)
      permission_sets = ["AdministratorAccess", "HybridAccess"] // permissions the user/group will have in the account(s)
      account_ids = [                                             // account(s) the group will have access to. Permissions they will have in account are above line
        local.account1_account_id,
        # local.account2_account_id,
        # local.account3_account_id, // these are defined in a locals.tf file, example is in this directory
        # local.account4_account_id,
      ]
    },
    Audit : {
      principal_name  = "Audit"
      principal_type  = "GROUP"
      principal_idp   = "INTERNAL" # type of Identity Provider you are using. Valid values are "INTERNAL" (using Identity Store) or "EXTERNAL" (using external IdP such as EntraID, Okta, Google, etc.)
      permission_sets = ["S3ReadOnlyAccess"]
      account_ids = [
        local.account1_account_id,
        # local.account2_account_id,
        # local.account3_account_id,
        # local.account4_account_id,
      ]
    },
  }

}
