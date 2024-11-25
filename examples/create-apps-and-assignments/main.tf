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
    }
  }

  // Create desired USERS in IAM Identity Center
  sso_users = {
    nuzumaki : {
      group_membership = ["Admin"]
      user_name        = "nuzumaki"
      given_name       = "Naruto"
      family_name      = "Uzumaki"
      email            = "nuzumaki@hiddenleaf.village"
    },
    suchiha : {
      group_membership = ["Dev"]
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
      principal_name  = "Admin"                                   # name of the user or group you wish to have access to the account(s)
      principal_type  = "GROUP"                                   # entity type (user or group) you wish to have access to the account(s). Valid values are "USER" or "GROUP"
      principal_idp   = "INTERNAL"                                # type of Identity Provider you are using. Valid values are "INTERNAL" (using Identity Store) or "EXTERNAL" (using external IdP such as EntraID, Okta, Google, etc.)
      permission_sets = ["AdministratorAccess", "ViewOnlyAccess"] // permissions the user/group will have in the account(s)
      account_ids = [                                             // account(s) the group will have access to. Permissions they will have in account are above line
        local.account1_account_id,
        # local.account2_account_id,
        # local.account3_account_id, // these are defined in a locals.tf file, example is in this directory
        # local.account4_account_id,
      ]
    },
    Dev : {
      principal_name  = "Dev"
      principal_type  = "GROUP"
      principal_idp   = "INTERNAL" # type of Identity Provider you are using. Valid values are "INTERNAL" (using Identity Store) or "EXTERNAL" (using external IdP such as EntraID, Okta, Google, etc.)
      permission_sets = ["ViewOnlyAccess"]
      account_ids = [
        local.account1_account_id,
        # local.account2_account_id,
        # local.account3_account_id,
        # local.account4_account_id,
      ]
    },
  }

  // Applications
  sso_applications = {
    FirstApplication : {
      application_provider_arn = "arn:aws:sso::aws:applicationProvider/custom"
      description              = "I am the First Application"
      name                     = "FirstApplication"
      portal_options = {
        sign_in_options = {
          application_url = "http://example.com"
          origin          = "APPLICATION"
        }
        visibility = "ENABLED"
      }
      status              = "ENABLED"
      assignment_required = true
      assignments_access_scope = [
        {
          authorized_targets = ["FirstApplication"]
          scope              = "sso:account:access"
        }
      ]
      group_assignments = ["Dev"]
      user_assignments  = ["nuzumaki"]
      tags              = { ManagedBy = "Terraform" }
    },
    SecondApplication : {
      application_provider_arn = "arn:aws:sso::aws:applicationProvider/custom"
      description              = "I am the Second Application"
      name                     = "SecondApplication"
      portal_options = {
        sign_in_options = {
          application_url = "http://example2.com"
          origin          = "APPLICATION"
        }
        visibility = "ENABLED"
      }
      status              = "ENABLED"
      assignment_required = true
      assignments_access_scope = [
        {
          authorized_targets = ["FirstApplication", "SecondApplication"]
          scope              = "sso:account:access"
        }
      ]
      group_assignments = ["Admin"]
      user_assignments  = ["suchiha"]
    }
  }

}
