module "aws-iam-identity-center" {
    source = "../.." // local example


  sso_instance_access_control_attributes = {
    FirstName = { 
      attribute_name = "FirstName"
      source = ["$${path:name.givenName}"]
    }
    LastName = {
      attribute_name = "LastName"
      source = ["$${path:name.familyName}"]
    }
  }
}