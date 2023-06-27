# Groups
variable "sso_groups" {
  description = "Names of the groups you wish to create in IAM Identity Center"
  type    = map(any)
  default = {}
}

# Users
variable "sso_users" {
  description = "Names of the users you wish to create in IAM Identity Center"
  type    = map(any)
  default = {}
}

# Permission Sets
variable "permission_sets" {
  description = "Map of maps containing Permission Set names as keys. See permission_sets description in README for information about map values."
  type        = any
  default = {
    # key
    AdministratorAccess = {
      # values
      description      = "Provides full access to AWS services and resources.",
      session_duration = "PT2H",
      managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    }
  }
}

#  Account Assignments
variable "account_assignments" {
  description = "List of maps containing mapping between user/group, permission set and assigned accounts list. See account_assignments description in README for more information about map values."
  type = map(any)

  default = {}
}
