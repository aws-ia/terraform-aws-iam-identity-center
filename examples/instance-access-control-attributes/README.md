<!-- BEGIN_TF_DOCS -->
This directory contains examples of using the module to **create** instance access control attributes.

```hcl
  sso_instance_access_control_attributes = [
    {
      attribute_name = "FirstName"
      source = ["$${path:name.givenName}"]
    },
    {
      attribute_name = "LastName"
      source = ["$${path:name.familyName}"]
    }
  ]
```

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