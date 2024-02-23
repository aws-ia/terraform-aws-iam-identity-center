terraform {
  required_version = ">= 0.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.35.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 0.55.0"
    }
  }
}
