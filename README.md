# Setup AWS Account IAM Roles, Add Account to the Valtix Contoller
Create IAM roles and prepare your AWS account to enable Valtix Controller access your account and deploy Valtix Security Gateways.

# Requirements
1. Enable terraform to access your aws account. Check here for the options https://registry.terraform.io/providers/hashicorp/aws/latest/docs.
1. Login to the Valtix Dashboard and generate an API Key using the instructions provided here: https://registry.terraform.io/providers/valtix-security/valtix/latest/docs

## Argument Reference

* `prefix` - (Required) Prefix added to all the resources created on the AWS account
* `controller_aws_account_number` - (Required) AWS controller account number provided by Valtix
* `valtix_api_key_file` - (Required) Valtix API Key JSON file downloaded from the Valtix Controller. This is used to get the external id from the Valtix Controller that is used in the trust relationship for cross account iam role
* `deployment_name` - (Optional) Valtix Deployment Name. Ask Valtix for this information. Default value is `prod1` unless you work with Valtix for a custom deployment
* `s3_bucket` - (Optional) S3 bucket name to store VPC Flow Logs, DNS Query Logs and optionally CloudTrail events. Set this to empty string if Discovery features are not required, default is empty (S3 bucket is NOT created) 
* `object_duration` - (Optional) Number of days after which the objects in the above S3 bucket are deleted (Default 1 day)
* `create_cloud_trail` - (Optional) true/false. Create a new multi-region CloudTrail and log the events to the provided S3 Bucket. S3 Bucket must be provided for this variable to take effect. If you already have a multi-region CloudTrail in your account, set this value to false to not create another CloudTrail. (Default true and is applicable only if `s3_bucket` is defined)
* `valtix_aws_cloud_account_name` - (Optional) Name used to represent this AWS Account on the Valtix Controller. If the value is empty, the account is not added. Default is empty
* `inventory_regions` - (Optional) List of AWS regions that Valtix Controller can monitor and update the inventory for dynamic security policies, this is used only when `valtix_aws_cloud_account_name` is not empty

### These parameters are required when run as root module (by cloning this code and run), otherwise the parent module would have to set the credentials and region
* `aws_credentials_profile` - (Optional) Required when run as root module. The profile name to use to login to the AWS account to add the IAM roles as described in this document.
* `region` - (Optional) Required when run as root module. AWS Region (Home region for CloudTrail, S3 Bucket)

## Outputs

* `cloud_account_name` - Valtix Cloud Account Name (same as input variable `valtix_aws_cloud_account_name`)
* `cloudtrail` - Map of CloudTrail name and arn
    ```
    {
      "arn" = "cloud_trail-arn"
      "name" = "cloud_trail-name"
    }
    ```
* `external_id` - Controller IAM Role external id, this is sensitive. Use `terraform output -json` to get the value. If the cloud account is onboarded in this module, then you don't need this value
* `s3_bucket` - Map of S3 Bucket name and arn
    ```
    {
      "arn" = "s3_bucket-arn"
      "name" = "s3_bucket-name"
    }
    ```
* `valtix_controller_role` - Map of Valtix Controller IAM Role's name and arn
    ```
    {
      "arn" = "valtix_controller_role-arn"
      "name" = "valtix_controller_role-name"
    }
    ```
* `valtix_controller_role_arn` - IAM Role used by the Valtix Controller to manage the AWS account (Backward Compatibility, use the map above for new deployments)
* `valtix_firewall_role` - Map of Valtix Gateway/Firewall IAM Role's name and arn
    ```
    {
      "arn" = "valtix_firewall_role-arn"
      "name" = "valtix_firewall_role-name"
    }
    ```
* `valtix_inventory_role` - Map of Valtix Inventory IAM Role's name and arn
    ```
    {
      "arn" = "valtix_inventory_role-arn"
      "name" = "valtix_inventory_role-name"
    }
    ```
* `z_console_urls` - Friendly AWS Console URLs for the IAM roles 

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

## Using as a module (non-root module)

Create a tf file with the following content

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
  region  = "us-east-1"
}

provider "valtix" {
  api_key_file = file("valtix_api.json")
}

module "csp_setup" {
  source                        = "github.com/valtix-security/terraform-aws-setup"
  # define the values for all the variables (use values-sample as a reference)
  deployment_name               = "prod1"
  prefix                        = "valtix"
  controller_aws_account_number = "valtix-aws-account-number"
  s3_bucket                     = "valtix-12345"
  object_duration               = 1
  create_cloud_trail            = true
  # required only if you intend to onboard the account to the Valtix Controller
  valtix_aws_cloud_account_name = "aws-account-name-on-valtix"
  inventory_regions             = ["us-east-1", "us-east-2"]
}
```
