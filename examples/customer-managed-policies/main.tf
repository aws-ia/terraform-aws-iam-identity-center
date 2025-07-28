data "aws_organizations_organization" "org" {}

module "aws-iam-identity-center" {
  source = "../.." // local example
  # source = "aws-ia/iam-identity-center/aws" // remote example

  existing_sso_groups = {
    AWSControlTowerAdmins : {
      group_name = "AWSControlTowerAdmins" # this must be the name of a sso group that already exists in your AWS account
    }
  }

  sso_groups = {
    Admin : {
      group_name        = "Admin"
      group_description = "Admin Group"
    },
    Dev : {
      group_name        = "Dev"
      group_description = "Dev Group"
    },
  }
  sso_users = {
    nuzumaki : {
      group_membership = ["Admin", "Dev", "AWSControlTowerAdmins"]
      user_name        = "nuzumaki"
      given_name       = "Naruto"
      family_name      = "Uzumaki"
      email            = "nuzumaki@hiddenleaf.village"
    },
    suchiha : {
      group_membership = ["Dev", "AWSControlTowerAdmins"]
      user_name        = "suchiha"
      given_name       = "Sasuke"
      family_name      = "Uchiha"
      email            = "suchiha@hiddenleaf.village"
    },
  }

  existing_permission_sets = {
    AWSAdministratorAccess : {
      permission_set_name = "AWSAdministratorAccess" # this must be the name of a permission set that already exists in your AWS account
    },
  }

  permission_sets = {
    AdministratorAccess = {
      description          = "Provides full access to AWS services and resources",
      session_duration     = "PT3H",
      aws_managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]

      customer_managed_policies = [
        "MyExampleOrgAdminAccess",
      ]

      tags = { ManagedBy = "Terraform" }
    },
    ViewOnlyAccess = {
      description          = "This policy grants permissions to view resources and basic metadata across all AWS services",
      session_duration     = "PT3H",
      aws_managed_policies = ["arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"]
      managed_policy_arn   = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"

      customer_managed_policies = [
        {
          name = "MyExampleOrgViewOnlyAccess"
          path = "/foo/example/"
        }
      ]

      permissions_boundary = {
        managed_policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
      }
      tags = { ManagedBy = "Terraform" }
    },
  }
  account_assignments = {
    Admin : {
      principal_name = "Admin"
      principal_type = "GROUP"
      principal_idp  = "INTERNAL"
      permission_sets = [
        "AdministratorAccess",
        "ViewOnlyAccess",
        // existing permission set
        "AWSAdministratorAccess",
      ]
      account_ids = [
        // replace with your own account id
        local.account1_account_id,
        # local.account2_account_id
        # local.account3_account_id
        # local.account4_account_id
      ]
    },
    Dev : {
      principal_name = "Dev"
      principal_type = "GROUP"
      principal_idp  = "INTERNAL"
      permission_sets = [
        "ViewOnlyAccess",
      ]
      account_ids = [
        // replace with your own account id
        local.account1_account_id,
        # local.account2_account_id
        # local.account3_account_id
        # local.account4_account_id
      ]
    },
  }
}
