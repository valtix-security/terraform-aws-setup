terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    valtix = {
      source = "valtix-security/valtix"
    }
    time = {
      source = "hashicorp/time"
    }
  }
}

data "aws_caller_identity" "current" {}
