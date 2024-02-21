<!-- BEGIN_TF_DOCS -->
# Terraform Module Project

:no\_entry\_sign: Do not edit this readme.md file. To learn how to change this content and work with this repository, refer to CONTRIBUTING.md

## Readme Content

This file will contain any instructional information about this module.

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
| [aws_identitystore_user.sso_users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_user) | resource |
| [aws_ssoadmin_account_assignment.account_assignment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_ssoadmin_customer_managed_policy_attachment.pset_customer_managed_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_customer_managed_policy_attachment) | resource |
| [aws_ssoadmin_managed_policy_attachment.pset_aws_managed_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_managed_policy_attachment) | resource |
| [aws_ssoadmin_permission_set.pset](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set) | resource |
| [aws_identitystore_group.existing_sso_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_group) | data source |
| [aws_identitystore_group.identity_store_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_group) | data source |
| [aws_identitystore_user.existing_sso_users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_user) | data source |
| [aws_identitystore_user.identity_store_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_user) | data source |
| [aws_ssoadmin_instances.sso_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |
| [aws_ssoadmin_permission_set.existing_permission_sets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_permission_set) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_assignments"></a> [account\_assignments](#input\_account\_assignments) | List of maps containing mapping between user/group, permission set and assigned accounts list. See account\_assignments description in README for more information about map values. | `map(any)` | `{}` | no |
| <a name="input_permission_sets"></a> [permission\_sets](#input\_permission\_sets) | Map of maps containing Permission Set names as keys. See permission\_sets description in README for information about map values. | `any` | <pre>{<br>  "AdministratorAccess": {<br>    "description": "Provides full access to AWS services and resources.",<br>    "managed_policies": [<br>      "arn:aws:iam::aws:policy/AdministratorAccess"<br>    ],<br>    "session_duration": "PT2H"<br>  }<br>}</pre> | no |
| <a name="input_sso_groups"></a> [sso\_groups](#input\_sso\_groups) | Names of the groups you wish to create in IAM Identity Center | `map(any)` | `{}` | no |
| <a name="input_sso_users"></a> [sso\_users](#input\_sso\_users) | Names of the users you wish to create in IAM Identity Center | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_assignment_data"></a> [account\_assignment\_data](#output\_account\_assignment\_data) | Tuple containing account assignment data |
| <a name="output_principals_and_assignments"></a> [principals\_and\_assignments](#output\_principals\_and\_assignments) | Map containing account assignment data |
<!-- END_TF_DOCS -->