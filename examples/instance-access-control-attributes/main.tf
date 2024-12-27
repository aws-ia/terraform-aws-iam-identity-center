module "aws-iam-identity-center" {
    source = "../.." // local example

  //Create desired access control attributes
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
}