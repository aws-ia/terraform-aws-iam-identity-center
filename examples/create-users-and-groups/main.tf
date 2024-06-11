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
    NarutoUzumaki : {
      group_membership = ["Admin", "Dev", "QA", "Audit"]
      user_name        = "nuzumaki"
      given_name       = "Naruto"
      family_name      = "Uzumaki"
      email            = "nuzumaki@hiddenleaf.village"
    },
    SasukeUchiha : {
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
    ViewOnlyAccess = {
      description          = "Provides AWS view only permissions.",
      session_duration     = "PT3H", // how long until session expires - this means 3 hours. max is 12 hours
      aws_managed_policies = ["arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"]
      tags                 = { ManagedBy = "Terraform" }
    },
  }

  // Assign users/groups access to accounts with the specified permissions
  account_assignments = {
    Admin : {
      principal_name  = "Admin"                                   // name of the user or group you wish to have access to the account(s)
      principal_type  = "GROUP"                                   // entity type (user or group) you wish to have access to the account(s). Valid values are "USER" or "GROUP"
      permission_sets = ["AdministratorAccess", "ViewOnlyAccess"] // permissions the user/group will have in the account(s)
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
      permission_sets = ["ViewOnlyAccess"]
      account_ids = [
        local.account1_account_id,
        # local.account2_account_id,
        # local.account3_account_id,
        # local.account4_account_id,
      ]
    },
  }

}
