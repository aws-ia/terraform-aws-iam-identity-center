<!-- BEGIN_TF_DOCS -->
This directory contains examples of using the module to **create** applications, application assignments configurations, users, groups and application assignments to both users and groups

**IMPORTANT:** Ensure that the name of your object matches the name of your principal (e.g. user name or group name). See the following example with object/principal names 'Admin' and 'nuzumaki':

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

  // Create desired Applications in IAM Identity Center
  sso_applications = {
    FirstApplication : {
      application_provider_arn = "arn:aws:sso::aws:applicationProvider/custom"
      description              = "I am the First Application"
      name                     = "FirstApplication"
      portal_options = {
        sign_in_options = {
          application_url = "http://example.com"
          origin          = "APPLICATION"
        }
        visibility = "ENABLED"
      }
      status              = "ENABLED"
      assignment_required = true
      assignments_access_scope = [
        {
          authorized_targets = ["FirstApplication"]
          scope              = "sso:account:access"
        }
      ]
      group_assignments = ["Dev"]
      user_assignments  = ["nuzumaki"]
    }
  }

```

These names are referenced throughout the module. Failure to do this may lead to unintentional errors such as the following:

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

To resolve this, ensure your object and principal names are the same and re-run `terraform plan` and `terraform apply`.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws-iam-identity-center"></a> [aws-iam-identity-center](#module\_aws-iam-identity-center) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.account1_account_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->