# - IAM Identity Center Dynamic Group Creation -
resource "aws_identitystore_group" "sso_groups" {
  for_each          = var.sso_groups == null ? {} : var.sso_groups
  identity_store_id = local.sso_instance_id
  display_name      = each.value.group_name
  description       = each.value.group_description
}


# - IAM Identity Center Dynamic User Creation -
resource "aws_identitystore_user" "sso_users" {
  for_each          = var.sso_users == null ? {} : var.sso_users
  identity_store_id = local.sso_instance_id

  # -- PROFILE DETAILS --
  # - Primary Information -
  // The default is the provided given name and family name.
  # display_name = lookup(each.value, "display_name", join(" ", [each.value.given_name, each.value.family_name]))
  display_name = each.value.display_name != null ? each.value.display_name : join(" ", [each.value.given_name, each.value.family_name])

  //(Required, Forces new resource) A unique string used to identify the user. This value can consist of letters, accented characters, symbols, numbers, and punctuation. This value is specified at the time the user is created and stored as an attribute of the user object in the identity store. The limit is 128 characters
  user_name = each.value.user_name

  //(Required) Details about the user's full name. Detailed below
  name {
    // (Required) First name
    given_name = each.value.given_name
    // (Optional) Middle name
    // Default value is null.
    middle_name = each.value.middle_name
    // (Required) Last name
    family_name = each.value.family_name
    // (Optional) The name that is typically displayed when the name is shown for display.
    // Default value is the provided given name and family name.
    formatted = each.value.name_formatted != null ? each.value.name_formatted : join(" ", [each.value.given_name, each.value.family_name])
    // (Optional) The honorific prefix of the user.
    // Default value is null.
    honorific_prefix = each.value.honorific_prefix
    // (Optional) The honorific suffix of the user
    // Default value is null.
    honorific_suffix = each.value.honorific_suffix
  }

  // (Optional) Details about the user's email. At most 1 email is allowed. Detailed below.
  // Required for this module to ensure users have an email on file for resetting password and receiving OTP.
  emails {
    // (Optional) The email address. This value must be unique across the identity store.
    // Required for this module as explained above.
    value = each.value.email
    //(Optional) When true, this is the primary email associated with the user.
    // Default value is true.
    primary = each.value.is_primary_email
    // (Optional) The type of email.
    // Default value is null.
    type = each.value.email_type
  }

  //(Optional) Details about the user's phone number. At most 1 phone number is allowed. Detailed below.
  phone_numbers {
    //(Optional) The user's phone number.
    // Default value is null.
    value = each.value.phone_number
    // (Optional) When true, this is the primary phone number associated with the user.
    // Default value is true.
    primary = each.value.is_primary_phone_number
    // (Optional) The type of phone number.
    // // Default value is null.
    type = each.value.phone_number_type
  }

  // (Optional) Details about the user's address. At most 1 address is allowed. Detailed below.
  addresses {
    // (Optional) The country that this address is in.
    // Default value is null.
    country = each.value.country
    // (Optional) The address locality. You can use this for City/Town/Village
    // Default value is null.
    locality = each.value.locality
    //(Optional) The name that is typically displayed when the address is shown for display.
    // Default value is the provided street address, locality, region, postal code, and country.
    formatted = each.value.address_formatted != null ? each.value.address_formatted : join(" ", [lookup(each.value, "street_address", ""), lookup(each.value, "locality", ""), lookup(each.value, "region", ""), lookup(each.value, "postal_code", ""), lookup(each.value, "country", "")])
    // Default value is null.
    postal_code = each.value.postal_code
    // (Optional) When true, this is the primary address associated with the user.
    // Default value is null.
    primary = each.value.is_primary_address
    // (Optional) The region of the address. You can use this for State/Parish/Province.
    // Default value is true.
    region = each.value.region
    // (Optional) The street of the address.
    // Default value is null.
    street_address = each.value.street_address
    // (Optional) The type of address.
    // Default value is null.
    type = each.value.address_type
  }

  # -- Additional information --
  // (Optional) The user type.
  // Default value is null.
  user_type = each.value.user_type
  // (Optional) The user's title. Ex. Developer, Principal Architect, Account Manager, etc.
  // Default value is null.
  title = each.value.title
  // (Optional) The user's geographical region or location. Ex. US-East, EU-West, etc.
  // Default value is null.
  locale = each.value.locale
  // (Optional) An alternate name for the user.
  // Default value is null.
  nickname = each.value.nickname
  // (Optional) The preferred language of the user.
  // Default value is null.
  preferred_language = each.value.preferred_language
  // (Optional) An URL that may be associated with the user.
  // Default value is null.
  profile_url = each.value.profile_url
  // (Optional) The user's time zone.
  // Default value is null.
  # timezone = each.value.timezone
  timezone = each.value.timezone

  # ** IMPORTANT - NOT CURRENTLY SUPPORTED - Will add support when Terraform resource is updated. **
  # employee_number = lookup(each.value, "employee_number", null)
  # cost_center = lookup(each.value, "cost_center", null)
  # organization = lookup(each.value, "organization", null)
  # division = lookup(each.value, "division", null)
  # department = lookup(each.value, "department", null)
  # manager = lookup(each.value, "manager", null)

}


# - Identity Store Group Membership -
# New Users with New Groups
resource "aws_identitystore_group_membership" "sso_group_membership" {
  for_each          = local.users_and_their_groups
  identity_store_id = local.sso_instance_id

  group_id  = (contains(local.this_groups, each.value.group_name) ? aws_identitystore_group.sso_groups[each.value.group_name].group_id : data.aws_identitystore_group.existing_sso_groups[each.value.group_name].group_id)
  member_id = (contains(local.this_users, each.value.user_name) ? aws_identitystore_user.sso_users[each.value.user_name].user_id : data.aws_identitystore_user.existing_sso_users[each.value.user_name].user_id)

}

# Existing Google Users with New Groups
resource "aws_identitystore_group_membership" "sso_group_membership_existing_google_sso_users" {
  for_each          = local.users_and_their_groups_existing_google_sso_users
  identity_store_id = local.sso_instance_id

  group_id  = (contains(local.this_groups, each.value.group_name) ? aws_identitystore_group.sso_groups[each.value.group_name].group_id : data.aws_identitystore_group.existing_sso_groups[each.value.group_name].group_id)
  member_id = data.aws_identitystore_user.existing_google_sso_users[each.value.user_name].user_id
  # member_id = (contains(local.this_existing_google_users, each.value.user_name) ? aws_identitystore_user.sso_users[each.value.user_name].user_id : data.aws_identitystore_user.existing_sso_users[each.value.user_name].user_id)

}


# - SSO Permission Set -
resource "aws_ssoadmin_permission_set" "pset" {
  for_each = var.permission_sets
  name     = each.key

  # lookup function retrieves the value of a single element from a map, when provided it's key.
  # if the given key does not exist, the default value (null) is returned instead

  instance_arn     = local.ssoadmin_instance_arn
  description      = lookup(each.value, "description", null)
  relay_state      = lookup(each.value, "relay_state", null)      // (Optional) URL used to redirect users within the application during the federation authentication process
  session_duration = lookup(each.value, "session_duration", null) // The length of time that the application user sessions are valid in the ISO-8601 standard
  tags             = lookup(each.value, "tags", {})
}


# - AWS Managed Policy Attachment -
resource "aws_ssoadmin_managed_policy_attachment" "pset_aws_managed_policy" {
  # iterate over the permission_sets map of maps, and set the result to be pset_name and pset_index
  # ONLY if the policy for each pset_index is valid.
  for_each = { for pset in local.pset_aws_managed_policy_maps : "${pset.pset_name}.${pset.policy_arn}" => pset }

  instance_arn       = local.ssoadmin_instance_arn
  managed_policy_arn = each.value.policy_arn
  permission_set_arn = aws_ssoadmin_permission_set.pset[each.value.pset_name].arn

  depends_on = [aws_ssoadmin_account_assignment.account_assignment]
}


# - Customer Managed Policy Attachment -
resource "aws_ssoadmin_customer_managed_policy_attachment" "pset_customer_managed_policy" {
  for_each = { for pset in local.pset_customer_managed_policy_maps : "${pset.pset_name}.${pset.policy_name}" => pset }

  instance_arn       = local.ssoadmin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.pset[each.value.pset_name].arn
  customer_managed_policy_reference {
    name = each.value.policy_name
    path = each.value.policy_path
  }

}


# - Inline Policy -
resource "aws_ssoadmin_permission_set_inline_policy" "pset_inline_policy" {
  for_each = { for pset in local.pset_inline_policy_maps : pset.pset_name => pset if can(pset.inline_policy) }

  inline_policy      = each.value.inline_policy
  instance_arn       = local.ssoadmin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.pset[each.key].arn
}

# - Permissions Boundary -
resource "aws_ssoadmin_permissions_boundary_attachment" "pset_permissions_boundary_aws_managed" {
  for_each = { for pset in local.pset_permissions_boundary_aws_managed_maps : pset.pset_name => pset if can(pset.boundary.managed_policy_arn) }

  instance_arn       = local.ssoadmin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.pset[each.key].arn
  permissions_boundary {
    managed_policy_arn = each.value.boundary.managed_policy_arn
  }
}

resource "aws_ssoadmin_permissions_boundary_attachment" "pset_permissions_boundary_customer_managed" {
  for_each = { for pset in local.pset_permissions_boundary_customer_managed_maps : pset.pset_name => pset if can(pset.boundary.customer_managed_policy_reference) }

  instance_arn       = local.ssoadmin_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.pset[each.key].arn
  permissions_boundary {
    customer_managed_policy_reference {
      name = each.value.boundary.customer_managed_policy_reference.name
      path = can(each.value.boundary.customer_managed_policy_reference.path) ? each.value.boundary.customer_managed_policy_reference.path : "/"
    }

  }
}

resource "aws_ssoadmin_account_assignment" "account_assignment" {
  for_each = local.principals_and_their_account_assignments // for_each arguement must be a map, or set of strings. Tuples won't work

  instance_arn       = local.ssoadmin_instance_arn
  permission_set_arn = contains(local.this_permission_sets, each.value.permission_set) ? aws_ssoadmin_permission_set.pset[each.value.permission_set].arn : data.aws_ssoadmin_permission_set.existing_permission_sets[each.value.permission_set].arn

  principal_type = each.value.principal_type

  # Conditional use of resource or data source to reference the principal_id depending on if the principal_type is "GROUP" or "USER" and if the principal_idp is "INTERNAL" or "EXTERNAL". "INTERNAL" aligns with users or groups that were created with this module and use the default IAM Identity Store as the IdP. "EXTERNAL" aligns with users or groups that were created outside of this module (e.g. via external IdP such as EntraID, Okta, Google, etc.) and were synced via SCIM to IAM Identity Center.

  principal_id = each.value.principal_type == "GROUP" && each.value.principal_idp == "INTERNAL" ? aws_identitystore_group.sso_groups[each.value.principal_name].group_id : (each.value.principal_type == "USER" && each.value.principal_idp == "INTERNAL" ? aws_identitystore_user.sso_users[each.value.principal_name].user_id : (each.value.principal_type == "GROUP" && each.value.principal_idp == "EXTERNAL" ? data.aws_identitystore_group.existing_sso_groups[each.value.principal_name].group_id : (each.value.principal_type == "USER" && each.value.principal_idp == "EXTERNAL" ? data.aws_identitystore_user.existing_sso_users[each.value.principal_name].user_id : (each.value.principal_type == "USER" && each.value.principal_idp == "GOOGLE") ? data.aws_identitystore_user.existing_google_sso_users[each.value.principal_name].user_id : null)))

  target_id   = each.value.account_id
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_application" "sso_apps" {
  for_each                 = var.sso_applications == null ? {} : var.sso_applications
  name                     = each.value.name
  instance_arn             = local.ssoadmin_instance_arn
  application_provider_arn = each.value.application_provider_arn
  client_token             = each.value.client_token
  description              = each.value.description

  dynamic "portal_options" {
    for_each = each.value.portal_options != null ? [each.value.portal_options] : []
    content {
      visibility = portal_options.value.visibility
      dynamic "sign_in_options" {
        for_each = each.value.portal_options.sign_in_options != null ? [each.value.portal_options.sign_in_options] : []
        content {
          application_url = portal_options.value.sign_in_options.application_url
          origin          = portal_options.value.sign_in_options.origin
        }
      }
    }
  }
  tags = each.value.tags
}

# SSO - Applications Assigments Configuration
resource "aws_ssoadmin_application_assignment_configuration" "sso_apps_assignments_configs" {
  for_each = {
    for idx, assignment_config in local.apps_assignments_configs :
    "${assignment_config.app_name}-assignment-config" => assignment_config
  }
  application_arn     = aws_ssoadmin_application.sso_apps[each.value.app_name].application_arn
  assignment_required = each.value.assignment_required
}

# SSO - Application Assignments access scope
resource "aws_ssoadmin_application_access_scope" "sso_apps_assignments_access_scope" {
  for_each = {
    for idx, app_access_scope in local.apps_assignments_access_scopes :
    "${app_access_scope.app_name}-${app_access_scope.scope}" => app_access_scope
  }
  application_arn = aws_ssoadmin_application.sso_apps[each.value.app_name].application_arn
  authorized_targets = [
    for target in each.value.authorized_targets : aws_ssoadmin_application.sso_apps[target].application_arn
  ]
  #authorized_targets = each.value.authorized_targets
  scope = each.value.scope
}

# SSO - Applications Assignments
# Groups assignments
resource "aws_ssoadmin_application_assignment" "sso_apps_groups_assignments" {
  for_each = {
    for idx, assignment in local.apps_groups_assignments :
    "${assignment.app_name}-${assignment.group_name}" => assignment
  }
  application_arn = aws_ssoadmin_application.sso_apps[each.value.app_name].application_arn
  principal_id    = (contains(local.this_groups, each.value.group_name) ? aws_identitystore_group.sso_groups[each.value.group_name].group_id : data.aws_identitystore_group.existing_sso_groups[each.value.group_name].group_id)
  principal_type  = each.value.principal_type
}

# Users assignments
resource "aws_ssoadmin_application_assignment" "sso_apps_users_assignments" {
  for_each = {
    for idx, assignment in local.apps_users_assignments :
    "${assignment.app_name}-${assignment.user_name}" => assignment
  }
  application_arn = aws_ssoadmin_application.sso_apps[each.value.app_name].application_arn
  principal_id    = (contains(local.this_users, each.value.user_name) ? aws_identitystore_user.sso_users[each.value.user_name].user_id : data.aws_identitystore_user.existing_sso_users[each.value.user_name].user_id)
  principal_type  = each.value.principal_type
}

# SSO Instance Access Control Attributes
resource "aws_ssoadmin_instance_access_control_attributes" "sso_access_control_attributes" {
  count        = length(var.sso_instance_access_control_attributes) <= 0 ? 0 : 1
  instance_arn = local.ssoadmin_instance_arn
  dynamic "attribute" {
    for_each = var.sso_instance_access_control_attributes
    content {
      key = attribute.key
      value {
        source = attribute.value.source
      }
    }
  }
}
