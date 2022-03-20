# Setup AWS Account IAM Roles, Add Account to the Valtix Contoller
Create IAM roles and prepare your AWS account to enable Valtix Controller access your account and deploy Valtix Security Gateways.

# Requirements
1. Enable terraform to access your aws account. Check here for the options https://registry.terraform.io/providers/hashicorp/aws/latest/docs.
1. Login to the Valtix Dashboard and generate an API Key using the instructions provided here: https://registry.terraform.io/providers/valtix-security/valtix/latest/docs

## Argument Reference

* `valtix_api_key_file` - (Required) Valtix API Key JSON file downloaded from the Valtix Dashboard
* `deployment_name` - (Required) Valtix Deployment Name provided by Valtix
* `prefix` - (Required) Prefix added to all the resources created on the AWS account
* `controller_aws_account_number` - (Required) AWS controller account number provided by Valtix
* `s3_bucket` - (Optional) S3 bucket name for VPC flow logs and DNS query logs for Valtix Realtime Discovery. Creates all-region CloudTrail to log into this bucket. If empty, then CloudTrail and S3 bucket are not created
* `object_duration` - (Optional) Number of days after which the objects in the s3 bucket are deleted (default 1 day)
* `aws_credentials_profile` - (Optional) Required when run as root module. The profile name to use to login to the AWS account
* `valtix_aws_cloud_account_name` - (Required) Name to use for AWS Account on the Valtix Dashboard (Valtix Controller)
* `inventory_regions` - (Optional) List of AWS regions that Valtix Controller can monitor and update the inventory for dynamic security policies

## Outputs

* `valtix_controller_role_arn` - IAM Role used by the Valtix Controller to manage the AWS account
* `valtix_firewall_role_name` - IAM Role used by the Valtix Gateway EC2 instances
* `valtix_inventory_role_arn` - IAM Role used by EventBridge to push real time inventory updates to the Valtix Controller  

## Running as root module
```
git clone https://github.com/valtix-security/terraform-aws-setup.git
cd terraform-aws-setup
mv provider provider.tf
cp values.sample values
```

Edit `values` file with the appropriate values for the variables

```
terraform init
terraform apply -var-file values
```


## Using as a module

To use this repo as a terraform module, remove provider.tf file or comment out the content in that file. From a top level module, call this repo as a module

### Top level module (In directory at the same level as this repo)

```hcl
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
  profile = "profilename"
}

provider "valtix" {
  api_key_file = file("valtix_api.json")
}

module "csp_setup" {
  source                        = "github.com/valtix-security/terraform-aws-setup"
  deployment_name               = "prod1"
  prefix                        = "valtix"
  controller_aws_account_number = "valtix-aws-account-number"
  s3_bucket                     = "valtix-12345"
  object_duration               = 1
  valtix_aws_cloud_account_name = "aws-account-name-on-valtix"
  inventory_regions             = ["us-east-1", "us-east-2"]
}
```