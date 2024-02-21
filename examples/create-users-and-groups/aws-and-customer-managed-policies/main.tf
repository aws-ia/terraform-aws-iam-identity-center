module "aws-iam-identity-center" {
  source = "../../.." // local example
  # source = ""aws-ia/iam-identity-center/aws" // remote example

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
      description               = "Provides AWS view only permissions.",
      session_duration          = "PT3H", // how long until session expires - this means 3 hours. max is 12 hours
      aws_managed_policies      = ["arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"]
      customer_managed_policies = ["${aws_iam_policy.example.name}"] // ensure this policy exists in every AWS account you will grant access to
      tags                      = { ManagedBy = "Terraform" }
    },
    CustomerManaged1 = {
      description               = "Provides AWS view only permissions.",
      session_duration          = "PT3H", // how long until session expires - this means 3 hours. max is 12 hours
      customer_managed_policies = ["${aws_iam_policy.example.name}"]
      tags                      = { ManagedBy = "Terraform" }

    }
  }

  // Assign users/groups access to accounts with the specified permissions
  account_assignments = {
    Admin : {
      principal_name  = "Admin"                                   // name of the user or group you wish to have access to the account(s)
      principal_type  = "GROUP"                                   // entity type (user or group) you wish to have access to the account(s)
      permission_sets = ["AdministratorAccess", "ViewOnlyAccess"] // permissions the user/group will have in the account(s)
      account_ids = [                                             // account(s) the group will have access to. Permissions they will have in account are above line
        local.account1_account_id,                                // locals are used to allow for global changes to multiple account assignments
        # local.account2_account_id, // if hard coding the account ids, you would need to change them in every place you want to change
        # local.account3_account_id, // these are defined in a locals.tf file, example is in this directory
        # local.account4_account_id,
      ]
    },
    Dev : {
      principal_name  = "Dev"                                  // name of the user or group you wish to have access to the account(s)
      principal_type  = "GROUP"                                // entity type (user or group) you wish to have access to the account(s)
      permission_sets = ["ViewOnlyAccess", "CustomerManaged1"] // permissions the user/group will have in the account(s)
      account_ids = [                                          // account(s) the group will have access to. Permissions they will have in account are above line
        local.account1_account_id,                             // locals are used to allow for global changes to multiple account assignments
        # local.account2_account_id, // if hard coding the account ids, you would need to change them in every place you want to change
        # local.account3_account_id, // these are defined in a locals.tf file, example is in this directory
        # local.account4_account_id,
      ]
    },
  }
}
