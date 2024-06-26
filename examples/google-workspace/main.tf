module "aws-iam-identity-center" {
  source = "../.." // local example
  # source = "aws-ia/iam-identity-center/aws" // remote example

  # Create group
  sso_groups = {
    Admin : {
      group_name        = "Admin"
      group_description = "Admin IAM Identity Center Group"
    },
    Audit : {
      group_name        = "Audit"
      group_description = "Audit IAM Identity Center Group"
    },
  }
  # Assign Google user to groups
  existing_google_sso_users = {
    googleuser : {
      user_name        = "googleuser" # this must be the name of a user that already exists in your AWS account
      group_membership = ["Admin", "Audit"]
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
  account_assignments = {
    Admin : {
      principal_name  = "Admin"
      principal_type  = "GROUP"
      principal_idp   = "INTERNAL" # set to "INTERNAL" because group was created on AWS side, not synced from "EXTERNAL" IdP
      permission_sets = ["AdministratorAccess", "ViewOnlyAccess", ]
      account_ids = [              // account(s) the user will have access to. Permissions they will have in account are above line
        local.account1_account_id, // locals are used to allow for global changes to multiple account assignments
        # local.account2_account_id, // if hard coding the account ids, you would need to change them in every place you want to change
        # local.account3_account_id, // these are defined in a locals.tf file, example is in this directory
        # local.account4_account_id,
      ]
    },
    Audit : {
      principal_name  = "Audit"
      principal_type  = "GROUP"
      principal_idp   = "INTERNAL" # set to "INTERNAL" because group was created on AWS side, not synced from "EXTERNAL" IdP
      permission_sets = ["ViewOnlyAccess", ]
      account_ids = [              // account(s) the user will have access to. Permissions they will have in account are above line
        local.account1_account_id, // locals are used to allow for global changes to multiple account assignments
        # local.account2_account_id, // if hard coding the account ids, you would need to change them in every place you want to change
        # local.account3_account_id, // these are defined in a locals.tf file, example is in this directory
        # local.account4_account_id,
      ]
    },
    googleuser : {
      principal_name  = "googleuser"
      principal_type  = "USER"
      principal_idp   = "GOOGLE" # set to "GOOGLE" because user was created in Google Workspace IdP and was synced to AWS via SCIM
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
