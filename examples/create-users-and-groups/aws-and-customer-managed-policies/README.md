# Deployment with Customer Managed Policies

This example shows how you can leverage **Managed Policies** to grant access to your users/groups for your desired AWS accounts. **IMPORTANT**: The customer managed IAM policy must exist in every AWS account you wish to use it in **BEFORE** referencing it in the module. If not, you will receive an error because the referenced policy would not yet exist.
