# Fetch existing SSO Instance
data "aws_ssoadmin_instances" "sso_instance" {}

# Fetch existing AWS Organization
data "aws_organizations_organization" "organization" {}


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

# - Fetch of SSO Groups (externally defined) to be used for group membership assignment -
data "aws_identitystore_group" "existing_sso_groups" {
  for_each          = var.existing_sso_groups
  identity_store_id = local.sso_instance_id
  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = each.value.group_name
    }
  }
}


# - Fetch of SSO Users (externally defined) to be used for group membership assignment -
data "aws_identitystore_user" "existing_sso_users" {
  for_each          = var.existing_sso_users
  identity_store_id = local.sso_instance_id

  alternate_identifier {
    # Filter users by user_name (nuzumaki, suchiha, dovis, etc.)
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.value.user_name
    }
  }
}

# - Fetch of Google SSO Users (externally defined) to be used for group membership assignment -
data "aws_identitystore_user" "existing_google_sso_users" {
  for_each          = var.existing_google_sso_users
  identity_store_id = local.sso_instance_id

  alternate_identifier {
    # Filter users by user_name (nuzumaki, suchiha, dovis, etc.)
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.value.user_name
    }
  }
}

# - Fetch of Permissions sets (externally defined) to be used for account assignment -
data "aws_ssoadmin_permission_set" "existing_permission_sets" {
  for_each     = var.existing_permission_sets
  instance_arn = local.ssoadmin_instance_arn
  name         = each.value.permission_set_name
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


