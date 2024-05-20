output "account_assignment_data" {
  value       = local.flatten_account_assignment_data
  description = "Tuple containing account assignment data"

}

output "principals_and_assignments" {
  value       = local.principals_and_their_account_assignments
  description = "Map containing account assignment data"

}

output "sso_groups_ids" {
  value       = { for k, v in aws_identitystore_group.sso_groups : k => v.group_id }
  description = "A map of SSO groups ids created by this module"
}



output "principals_and_their_account_assignments" {
  value       = local.principals_and_their_account_assignments
  description = "Map of principals and their account assignments"

}
/* debug output 
output "accounts_ids_maps" {
  value       = local.accounts_ids_maps
  description = "A map of account ids"
}

output "pset_inline_policy_maps" {
  value       = local.pset_inline_policy_maps
  description = "A map of inline policies for permission sets"

}

output "pset_permissions_boundary_aws_managed_maps" {
  value       = local.pset_permissions_boundary_aws_managed_maps
  description = "A map of permissions boundary for permission"
}

output "pset_permissions_boundary_customer_managed_maps" {
  value       = local.pset_permissions_boundary_customer_managed_maps
  description = "A map of permissions boundary for permission"
}

*/
