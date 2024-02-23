# Fetch existing SSO Instance
data "aws_ssoadmin_instances" "sso_instance" {}


# The local variable 'users_and_their_groups' is a map of values for relevant user information.
# It contians a list of all users with the name of their group_assignments appended to the end of the string.
# This map is then fed into the 'identitystore_group' and 'identitystore_user' data sources with the 'for_each'
# meta argument to fetch necessary information (group_id, user_id) for each user. These values are needed
# to assign the sso users to groups.
# Ex: nuzumaki_Admin = {
# group_name = "Admin"
# user_name = "nuzumaki"
#     }
#     nuzumaki_Dev = {
# group_name = "Dev"
# user_name = "nuzumaki"
#     }
#     suchihaQA = {
# group_name = "QA"
# user_name = "suchiha"
#     }

# - Fetch of SSO Groups to be used for group membership assignment -
data "aws_identitystore_group" "existing_sso_groups" {
  for_each          = local.users_and_their_groups
  identity_store_id = local.sso_instance_id
  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = each.value.group_name
    }
  }
  // Prevents failure if data fetch is attempted before GROUPS are created
  depends_on = [aws_identitystore_group.sso_groups]
}


# - Fetch of SSO Users to be used for group membership assignment -
data "aws_identitystore_user" "existing_sso_users" {
  for_each          = local.users_and_their_groups
  identity_store_id = local.sso_instance_id

  alternate_identifier {
    # Filter users by user_name (nuzumaki, suchiha, dovis, etc.)
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.value.user_name
    }
  }
  // Prevents failure if data fetch is attempted before USERS are created
  depends_on = [aws_identitystore_user.sso_users]
}


# - Fetch of SSO Groups to be used for account assignments (for GROUPS) -
data "aws_identitystore_group" "identity_store_group" {
  for_each          = toset(local.account_assignments_for_groups)
  identity_store_id = local.sso_instance_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = each.value
    }
  }
  // Prevents failure if data fetch is attempted before GROUPS are created
  depends_on = [aws_identitystore_group.sso_groups]
}


# - Fetch of SSO Groups to be used for account assignments (for USERS) -
data "aws_identitystore_user" "identity_store_user" {
  for_each          = toset(local.account_assignments_for_users)
  identity_store_id = local.sso_instance_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.value
    }
  }
  // Prevents failure if data fetch is attempted before USERS are created
  depends_on = [aws_identitystore_user.sso_users]
}


# The local variable 'principals_and_their_permission_sets' is a map of values for relevant user information.
# It contians a list of all users with the name of their group_assignments appended to the end of the string.
# This map is then fed into the 'aws_ssoadmin_permission_set' data source with the 'for_each'meta argument to
# fetch necessary information (principal_id , parget_id) for each principal (user/group). These values are needed
# to assign permissions for users/groups to AWS accounts via account assignments.
# Format is 'Type:<principal_type>__Principal:<principal_name>__Permission:<permission_set>__Account:<account_id>'

# Ex: Type:GROUP__Principal:Admin__Permission:AdministratorAccess__Account:111111111111 = {
# principal_name = "Admin"
# principal_type = "GROUP"
# permission_sets = "AdministratorAccess"
# account_ids = "111111111111"
#     }
#     Type:GROUP__Principal:Admin__Permission:AdministratorAccess__Account:222222222222 = {
#       # principal_name = "Admin"
#       # principal_type = "GROUP"
#       # permission_sets = "AdministratorAccess"
#       # account_ids = "222222222222"
#     }
#     Type:GROUP__Principal:Admin__Permission:ViewOnlyAccess__Account:111111111111 = {
# principal_name = "Admin"
# principal_type = "GROUP"
# permission_sets = "ViewOnlyAccess"
# account_ids = "111111111111"
#     }

data "aws_ssoadmin_permission_set" "existing_permission_sets" {
  for_each     = local.principals_and_their_account_assignments
  instance_arn = local.ssoadmin_instance_arn
  name         = each.value.permission_set
  // Prevents failure if data fetch is attempted before Permission Sets are created
  depends_on = [aws_ssoadmin_permission_set.pset]
}
