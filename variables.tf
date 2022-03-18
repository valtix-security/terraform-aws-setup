variable "region" {
  description = "AWS Region, required only when being run as root module"
  default     = ""
}

variable "valtix_api_key_file" {
  description = "Valtix API Key json file name downloaded from the Valtix Dashboard, required only when being run as root module"
  default     = ""
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
  default     = ""
}

variable "object_duration" {
  description = "Duration (in days) after which the objects in the s3 bucket are deleted"
  default     = 1
}

variable "aws_credentials_profile" {
  description = "AWS Credentials Profile Name, required only when run as root module"
  default     = ""
}

variable "valtix_aws_cloud_account_name" {
  description = "Name to use for AWS Account on the Valtix Dashboard (Valtix Controller)"
}

variable "inventory_regions" {
  description = "Regions that Valtix Controller can monitor and update the inventory for dynamic security policies: us-east-1, us-east-2"
  default     = []
  type        = list(string)
}
