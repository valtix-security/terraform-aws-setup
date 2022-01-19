terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    valtix = {
      source = "valtix-security/valtix"
    }
  }
}

provider "aws" {
  region     = var.region
  profile    = var.aws_credentials_profile
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "valtix" {
  api_key_file = file(var.valtix_api_key_file)
}
