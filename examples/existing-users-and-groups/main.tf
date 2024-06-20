module "aws-iam-identity-center" {
  source = "../.." // local example
  # source = "aws-ia/iam-identity-center/aws" // remote example

  # Ensure these User/Groups already exist in your AWS account
  existing_sso_groups = {
    testgroup : {
      group_name = "testgroup" # this must be the name of a group that already exists in your AWS account
    },
  }
  existing_sso_users = {
    testuser : {
      user_name = "testuser" # this must be the name of a user that already exists in your AWS account
    },
  }


  # Create permissions sets backed by AWS managed policies
  permission_sets = {
    AdministratorAccess = {
      description          = "Provides AWS full access permissions.",
      session_duration     = "PT4H", // how long until session expires - this means 4 hours. max is 12 hours
      aws_managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
      tags                 = { ManagedBy = "Terraform" }
    },
    ViewOnlyAccess = {
      description          = "Provides AWS view only permissions.",
      session_duration     = "PT3H", // how long until session expires - this means 3 hours. max is 12 hours
      aws_managed_policies = ["arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"]
      tags                 = { ManagedBy = "Terraform" }
    },
  }


  # Assign users/groups access to accounts with the specified permissions
  # Ensure these User/Groups already exist in your AWS account
  account_assignments = {
    testgroup : {
      principal_name  = "testgroup"
      principal_type  = "GROUP"
      principal_idp   = "EXTERNAL"
      permission_sets = ["AdministratorAccess", "ViewOnlyAccess", ]
      account_ids = [              // account(s) the user will have access to. Permissions they will have in account are above line
        local.account1_account_id, // locals are used to allow for global changes to multiple account assignments
        # local.account2_account_id, // if hard coding the account ids, you would need to change them in every place you want to change
        # local.account3_account_id, // these are defined in a locals.tf file, example is in this directory
        # local.account4_account_id,
      ]
    },
    testuser : {
      principal_name  = "testuser"
      principal_type  = "USER"
      principal_idp   = "EXTERNAL"
      permission_sets = ["ViewOnlyAccess"]
      account_ids = [              // account(s) the user will have access to. Permissions they will have in account are above line
        local.account1_account_id, // locals are used to allow for global changes to multiple account assignments
        # local.account2_account_id, // if hard coding the account ids, you would need to change them in every place you want to change
        # local.account3_account_id, // these are defined in a locals.tf file, example is in this directory
        # local.account4_account_id,
      ]
    },
  }

}
