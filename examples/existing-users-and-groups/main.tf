module "aws-iam-identity-center" {
  source = "../.." // local example
  # source = "aws-ia/iam-identity-center/aws" // remote example

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

  # Ensure these User/Groups already exist in your AWS account

  // Assign users/groups access to accounts with the specified permissions
  account_assignments = {
    Admin : {
      principal_name  = "Admin"                                   // name of the user or group you wish to have access to the account(s)
      principal_type  = "GROUP"                                   // entity type (user or group) you wish to have access to the account(s). Valid values are "USER" or "GROUP"
      permission_sets = ["AdministratorAccess", "ViewOnlyAccess"] // permissions the user/group will have in the account(s)
      account_ids = [                                             // account(s) the group will have access to. Permissions they will have in account are above line
        local.account1_account_id,                                // locals are used to allow for global changes to multiple account assignments
        # local.account2_account_id, // if hard coding the account ids, you would need to change them in every place you want to change
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
        local.account2_account_id,
        local.account3_account_id,
        local.account4_account_id,
      ]
    },
  }

}
