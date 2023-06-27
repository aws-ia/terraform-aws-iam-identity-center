module "aws-iam-identity-center"{
  source = "./modules/aws-iam-identity-center" // local example
  # source = "novekm/iam-identity-center/aws" // remote example

  // Create permissions sets backed by AWS managed policies
  permission_sets = {
    CustomerManaged1 = {
      description      = "Provides AWS view only permissions.",
      session_duration = "PT3H", // how long until session expires - this means 3 hours. max is 12 hours
      customer_managed_policies = ["${aws_iam_policy.example1.name}"]
      tags             = { ManagedBy = "Terraform" }
    },
    CustomerManaged2 = {
      description      = "Provides AWS view only permissions.",
      session_duration = "PT3H", // how long until session expires - this means 3 hours. max is 12 hours
      customer_managed_policies = ["${aws_iam_policy.example2.name}"]
      tags             = { ManagedBy = "Terraform" }
    },
  }

  # Ensure these User/Groups already exist in your AWS account

  // Assign users/groups access to accounts with the specified permissions
  account_assignments = {
    Admin: {
      principal_name = "Admin" // name of the user or group you wish to have access to the account(s)
      principal_type = "GROUP" // entity type (user or group) you wish to have access to the account(s)
      permission_sets = ["CustomerManaged1", "CustomerManaged2"] // permissions the user/group will have in the account(s)
      account_ids    = [ // account(s) the group will have access to. Permissions they will have in account are above line
        local.account1_account_id,  // locals are used to allow for global changes to multiple account assignments
        # local.account2_account_id, // if hard coding the account ids, you would need to change them in every place you want to change
        # local.account3_account_id, // these are defined in a locals.tf file, example is in this directory
        # local.account4_account_id,
        ]
    },
    Dev: {
      principal_name = "Dev" // name of the user or group you wish to have access to the account(s)
      principal_type = "GROUP" // entity type (user or group) you wish to have access to the account(s)
      permission_sets = ["CustomerManaged2"] // permissions the user/group will have in the account(s)
      account_ids    = [ // account(s) the group will have access to. Permissions they will have in account are above line
        local.account1_account_id,  // locals are used to allow for global changes to multiple account assignments
        # local.account2_account_id, // if hard coding the account ids, you would need to change them in every place you want to change
        # local.account3_account_id, // these are defined in a locals.tf file, example is in this directory
        # local.account4_account_id,
        ]
    },
  }
}
