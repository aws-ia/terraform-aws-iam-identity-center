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
  // (Required) The name that is typically displayed when the user is referenced
  // The default is the provided given name and family name.
  # display_name = each.value.display_name
  display_name = join(" ", [each.value.given_name, each.value.family_name])

  //(Required, Forces new resource) A unique string used to identify the user. This value can consist of letters, accented characters, symbols, numbers, and punctuation. This value is specified at the time the user is created and stored as an attribute of the user object in the identity store. The limit is 128 characters
  user_name = each.value.user_name

  //(Required) Details about the user's full name. Detailed below
  name {
    // (Required) First name
    given_name = each.value.given_name
    // (Optional) Middle name
    // Default value is null.
    middle_name = lookup(each.value, "middle_name", null)
    // (Required) Last name
    family_name = each.value.family_name
    // (Optional) The name that is typically displayed when the name is shown for display.
    // Default value is the provided given name and family name.
    formatted = lookup(each.value, "name_formatted", join(" ", [each.value.given_name, each.value.family_name]))
    // (Optional) The honorific prefix of the user.
    // Default value is null.
    honorific_prefix = lookup(each.value, "honorific_prefix", null)
    // (Optional) The honorific suffix of the user
    // Default value is null.
    honorific_suffix = lookup(each.value, "honorific_suffix", null)
  }

  // (Optional) Details about the user's email. At most 1 email is allowed. Detailed below.
  // Required for this module to ensure users have an email on file for resetting password and receiving OTP.
  emails {
    // (Optional) The email address. This value must be unique across the identity store.
    // Required for this module as explained above.
    value = each.value.email
    //(Optional) When true, this is the primary email associated with the user.
    // Default value is true.
    primary = lookup(each.value, "is_primary_email", true)
    // (Optional) The type of email.
    // Default value is null.
    type = lookup(each.value, "email_type", null)
  }

  //(Optional) Details about the user's phone number. At most 1 phone number is allowed. Detailed below.
  phone_numbers {
    //(Optional) The user's phone number.
    // Default value is null.
    value = lookup(each.value, "phone_number", null)
    // (Optional) When true, this is the primary phone number associated with the user.
    // Default value is true.
    primary = lookup(each.value, "is_primary_phone_number", true)
    // (Optional) The type of phone number.
    // // Default value is null.
    type = lookup(each.value, "phone_number_type", null)
  }

  // (Optional) Details about the user's address. At most 1 address is allowed. Detailed below.
  addresses {
    // (Optional) The country that this address is in.
    // Default value is null.
    country = lookup(each.value, "country", null)
    // (Optional) The address locality. You can use this for City/Town/Village
    // Default value is null.
    locality = lookup(each.value, "locality", null)
    //(Optional) The name that is typically displayed when the address is shown for display.
    // Default value is the provided street address, locality, region, postal code, and country.
    formatted = lookup(each.value, "address_formatted", join(" ", [lookup(each.value, "street_address", ""), lookup(each.value, "locality", ""), lookup(each.value, "region", ""), lookup(each.value, "postal_code", ""), lookup(each.value, "country", "")]))
    // (Optional) The postal code of the address.
    // Default value is null.
    postal_code = lookup(each.value, "postal_code", null)
    // (Optional) When true, this is the primary address associated with the user.
    // Default value is null.
    primary = lookup(each.value, "is_primary_address", true)
    // (Optional) The region of the address. You can use this for State/Parish/Province.
    // Default value is true.
    region = lookup(each.value, "region", null)
    // (Optional) The street of the address.
    // Default value is null.
    street_address = lookup(each.value, "street_address", null)
    // (Optional) The type of address.
    // Default value is null.
    type = lookup(each.value, "address_type", null)
  }

  # -- Additional information --
  // (Optional) The user type.
  // Default value is null.
  user_type = lookup(each.value, "user_type", null)
  // (Optional) The user's title. Ex. Developer, Principal Architect, Account Manager, etc.
  // Default value is null.
  title = lookup(each.value, "title", null)
  // (Optional) The user's geographical region or location. Ex. US-East, EU-West, etc.
  // Default value is null.
  locale = lookup(each.value, "locale", null)
  // (Optional) An alternate name for the user.
  // Default value is null.
  nickname = lookup(each.value, "nickname", null)
  // (Optional) The preferred language of the user.
  // Default value is null.
  preferred_language = lookup(each.value, "preferred_language", null)
  // (Optional) An URL that may be associated with the user.
  // Default value is null.
  profile_url = lookup(each.value, "profile_url", null)
  // (Optional) The user's time zone.
  // Default value is null.
  # timezone = each.value.timezone
  timezone = lookup(each.value, "timezone", null)

  # ** IMPORTANT - NOT CURRENTLY SUPPORTED - Will add support when Terraform resource is updated. **
  # employee_number = lookup(each.value, "employee_number", null)
  # cost_center = lookup(each.value, "cost_center", null)
  # organization = lookup(each.value, "organization", null)
  # division = lookup(each.value, "division", null)
  # department = lookup(each.value, "department", null)
  # manager = lookup(each.value, "manager", null)

}


# - Identity Store Group Membership -
resource "aws_identitystore_group_membership" "sso_group_membership" {
  for_each          = local.users_and_their_groups
  identity_store_id = local.sso_instance_id

  group_id  = data.aws_identitystore_group.existing_sso_groups[each.key].group_id
  member_id = data.aws_identitystore_user.existing_sso_users[each.key].user_id
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
    path = "/"
  }

}


#  ! NOT CURRENTLY SUPPORTED !
# - Inline Policy -
# resource "aws_ssoadmin_permission_set_inline_policy" "pset_inline_policy" {
#   for_each = { for pset_name, pset_index in var.permission_sets : pset_name => pset_index if can(pset_index.inline_policy) }

#   inline_policy      = each.value.inline_policy[0]
#   instance_arn       = local.ssoadmin_instance_arn
#   permission_set_arn = aws_ssoadmin_permission_set.pset[each.key].arn
# }

resource "aws_ssoadmin_account_assignment" "account_assignment" {
  for_each = local.principals_and_their_account_assignments // for_each arguement must be a map, or set of strings. Tuples won't work

  instance_arn       = local.ssoadmin_instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.existing_permission_sets[each.key].arn

  principal_id   = each.value.principal_type == "GROUP" ? data.aws_identitystore_group.identity_store_group[each.value.principal_name].id : data.aws_identitystore_user.identity_store_user[each.value.principal_name].id
  principal_type = each.value.principal_type

  target_id   = each.value.account_id
  target_type = "AWS_ACCOUNT"
}
