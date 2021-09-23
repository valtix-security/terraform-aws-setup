# terraform-aws-valtix-iam
Create IAM roles and prepare your AWS account to enable Valtix Controller access your account and deploy Valtix Security Gateways. The repo provides a full working example. You can clone this and use this as a module from your other terraform scripts.

# Requirements
1. Enable terraform to access your aws account. Check here for the options https://registry.terraform.io/providers/hashicorp/aws/latest/docs.
1. Login to the Valtix Dashboard and generate an API Key using the instructions provided here: https://registry.terraform.io/providers/valtix-security/valtix/latest/docs

## Argument Reference

* `region` - (Required) AWS region to create S3 bucket
* `valtix_api_key_file` - (Required) Valtix API Key Json file downloaded from the Valtix Dashboard
* `deployment_name` - (Required) Valtix Deployment Name provided by Valtix
* `prefix` - (Required) Prefix appended to resources created
* `controller_aws_account_number` - (Required) AWS controller account number provided by Valtix
* `s3_bucket` - (Required) S3 bucket name for VPC flow logs and DNS query logs for Valtix Discovery
* `object_duration ` - (Optional) Number of days after which the objects in the s3 bucket are deleted (default 1 day)
* `spoke_vpc_tags` - (Required) A map of the tag name and value used to find the spoke vpcs for which dns and flow logs are enabled
  ```
  {
    tag1 = "value1"
    tag2 = "value2"
    tag3 = "spoke-*"
  }
  ```

## Outputs

* `valtix_controller_role_arn` - IAM Role used by the Valtix Controller to manage the AWS account
* `valtix_firewall_role_name` - IAM Role used by the Valtix Gateway EC2 instances
* `iam_external_id` - External ID that must be provided while adding AWS account to the Valtix Controller along with the controller role arn described above  

## Using as a module

To use this repo as a terraform module, remove provider.tf file or comment out the content in that file. From a top level module, call this repo as a module

### Top level module (In directory at the same level as this repo)

```
terraform {
  required_providers {
    valtix = {
      source = "valtix-security/valtix"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_creds_profile
}

provider "valtix" {
  api_key_file = file(var.valtix_api_key_file)
}

module "csp_setup" {
  source                        = "../terraform-aws-valtix-iam"
  region                        = "us-west-1"
  deployment_name               = "prod1"
  prefix                        = "valtix"
  controller_aws_account_number = "valtix-aws-account-number"
  s3_bucket                     = "valtix-12345"
  object_duration               = 1
  spoke_vpc_tags = {
    tag1 = "spoke-*"
  }
}
```