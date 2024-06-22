<!-- BEGIN_TF_DOCS -->
# AWS IAM Identity Center Terraform Module

## Features

- Dynamic User Creation
- Dynamic Group Creation
- Dynamic Group Membership Creation
- Dynamic Permission Set Creation
- Dynamic Account Assignment Creation
- Dynamic Reference of Existing Users
- Dynamic Reference of Existing Groups
- AWS Managed Policy Support
- Customer Managed Policy Support

## Important

- Locals are used to allow for global changes to multiple account assignments. If hard coding the account ids for your account assignments, you would need to change them in every place you want to reference the value. To simplify this, we recommend storing your desired account ids in [local values](https://developer.hashicorp.com/terraform/language/values/locals). See the `examples` directory for more information and sample code.
- When using **Customer Managed Policies** with account assignments, you must ensure these policies exist in all target accounts **before** using the module. Failure to do this will cause deployment errors because IAM Identity Center will attempt to reference policies that do not exist.
- **Ensure that the name of your object(s) match the name of your principal(s) (e.g. user name or group name). See the following example with object/principal names 'Admin' and 'nuzumaki'**:

```hcl
  sso_groups = {
    Admin : {
      group_name        = "Admin"
      group_description = "Admin IAM Identity Center Group"
    },
  }

  // Create desired USERS in IAM Identity Center
  sso_users = {
    nuzumaki : {
      group_membership = ["Admin",]
      user_name        = "nuzumaki"
      given_name       = "Naruto"
      family_name      = "Uzumaki"
      email            = "nuzumaki@hiddenleaf.village"
    },
  }

```

The object/principal names are referenced throughout the module. Failure to follow this guidance may lead to unintentional errors such as the following:

```
Error: Invalid index
│
│   on ../../main.tf line 141, in resource "aws_identitystore_group_membership" "sso_group_membership":
│  141:   member_id = (contains(local.this_users, each.value.user_name) ? aws_identitystore_user.sso_users[each.value.user_name].user_id : data.aws_identitystore_user.existing_sso_users[each.value.user_name].id)
│     ├────────────────
│     │ aws_identitystore_user.sso_users is object with 2 attributes
│     │ each.value.user_name is "nuzumaki"
│
│ The given key does not identify an element in this collection value.
```

To resolve this, ensure your object and principal names are the same (case-sensitive) and re-run `terraform plan` and `terraform apply`.

## Basic Usage - Create Users and Groups with AWS Managed Policies

```hcl
// This is a template file for a basic deployment.
// Modify the parameters below with actual values

module "aws-iam-identity-center" {
  source = "aws-ia/iam-identity-center/aws"

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
    nuzumaki : {
      group_membership = ["Admin", "Dev", "QA", "Audit"]
      user_name        = "nuzumaki"
      given_name       = "Naruto"
      family_name      = "Uzumaki"
      email            = "nuzumaki@hiddenleaf.village"
    },
    suchiha : {
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
      description          = "Provides AWS view only permissions.",
      session_duration     = "PT3H", // how long until session expires - this means 3 hours. max is 12 hours
      aws_managed_policies = ["arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"]
      tags                 = { ManagedBy = "Terraform" }
    },
    CustomPermissionAccess = {
      description          = "Provides CustomPoweruser permissions.",
      session_duration     = "PT3H", // how long until session expires - this means 3 hours. max is 12 hours
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess",
        "arn:aws:iam::aws:policy/AmazonS3FullAccess",
      ]
      inline_policy        = data.aws_iam_policy_document.CustomPermissionInlinePolicy.json

      // Only either managed_policy_arn or customer_managed_policy_reference can be specified.
      // Before using customer_managed_policy_reference, first deploy the policy to the account.
      // Don't in-place managed_policy_arn to/from customer_managed_policy_reference, delete it once.
      permissions_boundary = {
        // managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"

        customer_managed_policy_reference = {
          name = "ExamplePermissionsBoundaryPolicy"
          // path = "/"
        }
      }
      tags                 = { ManagedBy = "Terraform" }
    },
  }

  // Assign users/groups access to accounts with the specified permissions
  account_assignments = {
    Admin : {
      principal_name  = "Admin"                                   # name of the user or group you wish to have access to the account(s)
      principal_type  = "GROUP"                                   # principal type (user or group) you wish to have access to the account(s)
      principal_idp   = "INTERNAL"                                # type of Identity Provider you are using. Valid values are "INTERNAL" (using Identity Store) or "EXTERNAL" (using external IdP such as EntraID, Okta, Google, etc.)
      permission_sets = ["AdministratorAccess", "ViewOnlyAccess"] # permissions the user/group will have in the account(s)
      account_ids = [                                             # account(s) the group will have access to. Permissions they will have in account are above line
      "111111111111", // replace with your desired account id
      "222222222222", // replace with your desired account id
      ]
    },
    Audit : {
      principal_name  = "Audit"
      principal_type  = "GROUP"
      principal_idp   = "INTERNAL"
      permission_sets = ["ViewOnlyAccess"]
      account_ids = [
      "111111111111",
      "222222222222",
      ]
    },
  }

}
```

## Contributing

See the `CONTRIBUTING.md` file for information on how to contribute.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.35.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.55.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.35.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_identitystore_group.sso_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group) | resource |
| [aws_identitystore_group_membership.sso_group_membership](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group_membership) | resource |
| [aws_identitystore_group_membership.sso_group_membership_existing_google_sso_users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group_membership) | resource |
| [aws_identitystore_user.sso_users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_user) | resource |
| [aws_ssoadmin_account_assignment.account_assignment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_ssoadmin_customer_managed_policy_attachment.pset_customer_managed_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_customer_managed_policy_attachment) | resource |
| [aws_ssoadmin_managed_policy_attachment.pset_aws_managed_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_managed_policy_attachment) | resource |
| [aws_ssoadmin_permission_set.pset](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set) | resource |
| [aws_ssoadmin_permission_set_inline_policy.pset_inline_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set_inline_policy) | resource |
| [aws_ssoadmin_permissions_boundary_attachment.pset_permissions_boundary_aws_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permissions_boundary_attachment) | resource |
| [aws_ssoadmin_permissions_boundary_attachment.pset_permissions_boundary_customer_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permissions_boundary_attachment) | resource |
| [aws_identitystore_group.existing_sso_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_group) | data source |
| [aws_identitystore_user.existing_google_sso_users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_user) | data source |
| [aws_identitystore_user.existing_sso_users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_user) | data source |
| [aws_organizations_organization.organization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_ssoadmin_instances.sso_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |
| [aws_ssoadmin_permission_set.existing_permission_sets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_permission_set) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_assignments"></a> [account\_assignments](#input\_account\_assignments) | List of maps containing mapping between user/group, permission set and assigned accounts list. See account\_assignments description in README for more information about map values. | <pre>map(object({<br>    principal_name  = string<br>    principal_type  = string<br>    principal_idp   = string # acceptable values are either "INTERNAL" or "EXTERNAL"<br>    permission_sets = list(string)<br>    account_ids     = list(string)<br>  }))</pre> | `{}` | no |
| <a name="input_existing_google_sso_users"></a> [existing\_google\_sso\_users](#input\_existing\_google\_sso\_users) | Names of the existing Google users that you wish to reference from IAM Identity Center. | <pre>map(object({<br>    user_name        = string<br>    group_membership = optional(list(string), null) // only used if your IdP only syncs users, and you wish to manage which groups they should go in<br>  }))</pre> | `{}` | no |
| <a name="input_existing_permission_sets"></a> [existing\_permission\_sets](#input\_existing\_permission\_sets) | Names of the existing permission\_sets that you wish to reference from IAM Identity Center. | <pre>map(object({<br>    permission_set_name = string<br>  }))</pre> | `{}` | no |
| <a name="input_existing_sso_groups"></a> [existing\_sso\_groups](#input\_existing\_sso\_groups) | Names of the existing groups that you wish to reference from IAM Identity Center. | <pre>map(object({<br>    group_name = string<br>  }))</pre> | `{}` | no |
| <a name="input_existing_sso_users"></a> [existing\_sso\_users](#input\_existing\_sso\_users) | Names of the existing users that you wish to reference from IAM Identity Center. | <pre>map(object({<br>    user_name        = string<br>    group_membership = optional(list(string), null) // only used if your IdP only syncs users, and you wish to manage which groups they should go in<br>  }))</pre> | `{}` | no |
| <a name="input_permission_sets"></a> [permission\_sets](#input\_permission\_sets) | Permission Sets that you wish to create in IAM Identity Center. This variable is a map of maps containing Permission Set names as keys. See permission\_sets description in README for information about map values. | `any` | `{}` | no |
| <a name="input_sso_groups"></a> [sso\_groups](#input\_sso\_groups) | Names of the groups you wish to create in IAM Identity Center. | <pre>map(object({<br>    group_name        = string<br>    group_description = optional(string, null)<br>  }))</pre> | `{}` | no |
| <a name="input_sso_users"></a> [sso\_users](#input\_sso\_users) | Names of the users you wish to create in IAM Identity Center. | <pre>map(object({<br>    display_name     = optional(string)<br>    user_name        = string<br>    group_membership = list(string)<br>    # Name<br>    given_name       = string<br>    middle_name      = optional(string, null)<br>    family_name      = string<br>    name_formatted   = optional(string)<br>    honorific_prefix = optional(string, null)<br>    honorific_suffix = optional(string, null)<br>    # Email<br>    email            = string<br>    email_type       = optional(string, null)<br>    is_primary_email = optional(bool, true)<br>    # Phone Number<br>    phone_number            = optional(string, null)<br>    phone_number_type       = optional(string, null)<br>    is_primary_phone_number = optional(bool, true)<br>    # Address<br>    country            = optional(string, " ")<br>    locality           = optional(string, " ")<br>    address_formatted  = optional(string)<br>    postal_code        = optional(string, " ")<br>    is_primary_address = optional(bool, true)<br>    region             = optional(string, " ")<br>    street_address     = optional(string, " ")<br>    address_type       = optional(string, null)<br>    # Additional<br>    user_type          = optional(string, null)<br>    title              = optional(string, null)<br>    locale             = optional(string, null)<br>    nickname           = optional(string, null)<br>    preferred_language = optional(string, null)<br>    profile_url        = optional(string, null)<br>    timezone           = optional(string, null)<br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_assignment_data"></a> [account\_assignment\_data](#output\_account\_assignment\_data) | Tuple containing account assignment data |
| <a name="output_principals_and_assignments"></a> [principals\_and\_assignments](#output\_principals\_and\_assignments) | Map containing account assignment data |
| <a name="output_sso_groups_ids"></a> [sso\_groups\_ids](#output\_sso\_groups\_ids) | A map of SSO groups ids created by this module |
<!-- END_TF_DOCS -->