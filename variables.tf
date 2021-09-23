variable "region" {
  description = "AWS Region"
}

variable "valtix_api_key_file" {
  description = "Valtix API Key json file name downloaded from the Valtix Dashboard"
}

variable "deployment_name" {
  description = "Valtix Controller deployment name (ask Valtix)"
  default     = "prod1"
}

variable "prefix" {
  description = "Prefix for resources created in this template"
}

variable "controller_aws_account_number" {
  description = "Valtix provided aws account number (ask Valtix)"
}

variable "s3_bucket" {
  description = "Create S3 Bucket to store cloudtrail, route53 query logs and vpc flow logs"
}

variable "object_duration" {
  description = "Duration (in days) after which the objects in the s3 bucket are deleted"
  default = 1
}

variable "aws_credentials_profile" {
  description = "AWS Credentials Profil Name"
  default = ""
}

variable "aws_access_key" {
  description = "AWS Access Key"
  default = ""
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  default = ""
}

variable "spoke_vpc_tags" {
  description = "Spoke VPC filters to find VPCs for which DNS query logs and VPC flow logs are enabled"
  type = map(string)
  default = {
    "Name": "vpc-1"
  }
}
