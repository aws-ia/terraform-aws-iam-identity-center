# - Users and Groups -
locals {
  # Create a new local variable by flattening the complex type given in the variable "sso_users"
  flatten_user_data = flatten([
    for this_user in keys(var.sso_users) : [
      for group in var.sso_users[this_user].group_membership : {
        user_name  = var.sso_users[this_user].user_name
        group_name = group
      }
    ]
  ])

  users_and_their_groups = {
    for s in local.flatten_user_data : format("%s_%s", s.user_name, s.group_name) => s
  }

}


# - Permission Sets and Policies -
locals {
  # - Fetch SSO Instance ARN and SSO Instance ID -
  ssoadmin_instance_arn = tolist(data.aws_ssoadmin_instances.sso_instance.arns)[0]
  sso_instance_id       = tolist(data.aws_ssoadmin_instances.sso_instance.identity_store_ids)[0]

  # Iterate over the objects in var.permission sets, then evaluate the expression's 'pset_name'
  # and 'pset_index' with 'pset_name' and 'pset_index' only if the pset_index.managed_policies (AWS Managed Policy ARN)
  # produces a result without an error (i.e. if the ARN is valid). If any of the ARNs for any of the objects
  # in the map are invalid, the for loop will fail.

  # pset_name is the attribute name for each permission set map/object
  # pset_index is the corresponding index of the map of maps (which is the variable permission_sets)
  aws_managed_permission_sets      = { for pset_name, pset_index in var.permission_sets : pset_name => pset_index if can(pset_index.aws_managed_policies) }
  customer_managed_permission_sets = { for pset_name, pset_index in var.permission_sets : pset_name => pset_index if can(pset_index.customer_managed_policies) }

  #  ! NOT CURRENTLY SUPPORTED !
  # inline_policy_permission_sets = { for pset_name, pset_index in var.permission_sets : pset_name => pset_index if can(pset_index.inline_policy) }



  # When using the 'for' expression in Terraform:
  # [ and ] produces a tuple
  # { and } produces an object, and you must provide two result expressions separated by the => symbol
  # The 'flatten' function takes a list and replaces any elements that are lists with a flattened sequence of the list contents

  # create pset_name and managed policy maps list. flatten is needed because the result is a list of maps.name
  # This nested for loop will run only if each of the managed_policies are valid ARNs.

  # - AWS Managed Policies -
  pset_aws_managed_policy_maps = flatten([
    for pset_name, pset_index in local.aws_managed_permission_sets : [
      for policy in pset_index.aws_managed_policies : {
        pset_name  = pset_name
        policy_arn = policy
      } if pset_index.aws_managed_policies != null && can(pset_index.aws_managed_policies)
    ]
  ])

  # - Customer Managed Policies -
  pset_customer_managed_policy_maps = flatten([
    for pset_name, pset_index in local.customer_managed_permission_sets : [
      for policy in pset_index.customer_managed_policies : {
        pset_name   = pset_name
        policy_name = policy
        # path = path
      } if pset_index.customer_managed_policies != null && can(pset_index.customer_managed_policies)
    ]
  ])

  #  ! NOT CURRENTLY SUPPORTED !
  # - Inline Policy -
  #   pset_inline_policy_maps = flatten([
  #     for pset_name, pset_index in local.inline_policy_permission_sets : [
  #       for policy in pset_index.inline_policy : {
  #         pset_name  = pset_name
  #         inline_policy = policy
  #         # path = path
  #       } if pset_index.inline_policy != null && can(pset_index.inline_policy)
  #     ]
  #   ])

}


# - Account Assignments -
locals {
  # Create a new local variable by flattening the complex type given in the variable "account_assignments"
  # This will be a 'tuple'
  flatten_account_assignment_data = flatten([
    for this_assignment in keys(var.account_assignments) : [
      for account in var.account_assignments[this_assignment].account_ids : [
        for pset in var.account_assignments[this_assignment].permission_sets : {
          permission_set = pset
          principal_name = var.account_assignments[this_assignment].principal_name
          principal_type = var.account_assignments[this_assignment].principal_type
          account_id     = account
        }
      ]
    ]
  ])


  #  Convert the flatten_account_assignment_data tuple into a map.
  # Since we will be using this local in a for_each, it must either be a map or a set of strings
  principals_and_their_account_assignments = {
    for s in local.flatten_account_assignment_data : format("Type:%s__Principal:%s__Permission:%s__Account:%s", s.principal_type, s.principal_name, s.permission_set, s.account_id) => s
  }


  # iterates over account_assignents, sets that to be assignment.principal_name ONLY if the assignment.principal_type
  #is GROUP. Essentially stores all the possible 'assignments' (account assignments) that would be attached to a user group

  # same thing, for sso_users but for USERs not GROUPs

  # 'account_assignments_for_groups' is effectively a list of principal names where the account type is GROUP
  account_assignments_for_groups = [for assignment in var.account_assignments : assignment.principal_name if assignment.principal_type == "GROUP"]

  # 'account_assignments_for_users' is effectively a list of principal names where the account type is USER
  account_assignments_for_users = [for assignment in var.account_assignments : assignment.principal_name if assignment.principal_type == "USER"]
}
