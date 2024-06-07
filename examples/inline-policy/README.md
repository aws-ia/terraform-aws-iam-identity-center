<!-- BEGIN_TF_DOCS -->
This directory contains examples of using the module to create users and groups and assign permissions with **Inline Policies**.

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
| [aws_iam_policy_document.restrictAccessInlinePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_organizations_organization.org](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_ssm_parameter.account1_account_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->