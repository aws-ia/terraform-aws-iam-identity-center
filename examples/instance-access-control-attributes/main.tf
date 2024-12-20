module "aws-iam-identity-center" {
    source = "../.." // local example

}

data "aws_ssoadmin_instances" "instances" {}

resource "aws_ssoadmin_instance_access_control_attributes" "attributes" {
  instance_arn = tolist(data.aws_ssoadmin_instances.instances.arns)[0]
  attribute {
    key = "name"
    value {
      source = ["$${path:name.givenName}"]
    }
  }
}