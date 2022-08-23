output "valtix_controller_role_arn" {
  value = aws_iam_role.valtix_controller_role.arn
}

output "valtix_inventory_role_arn" {
  value = aws_iam_role.valtix_inventory_role.arn
}

output "valtix_firewall_role_name" {
  value = aws_iam_role.valtix_fw_role.name
}

output "cloud_account_name" {
  value = var.valtix_aws_cloud_account_name
}

output "external_id" {
  description = "External ID that needs to be provided while onboarding the AWS account onto the Valtix Controller"
  value       = valtix_external_id.iam_external_id.external_id
  sensitive   = true
}

output "s3_bucket" {
  value = var.s3_bucket
}

output "cloudtrail" {
  # get the first cloud trail, only one cloud trail is created but its
  # created using a map and condition, so use this workaround
  value = one([for ct in aws_cloudtrail.valtix_cloudtrail : { name : ct.name, arn : ct.arn }])
}

output "z_console_urls" {
  value = {
    controller-role = "https://console.aws.amazon.com/iamv2/home?#/roles/details/${aws_iam_role.valtix_controller_role.name}"
    firewall-role   = "https://console.aws.amazon.com/iamv2/home?#/roles/details/${aws_iam_role.valtix_fw_role.name}"
    inventory-role  = "https://console.aws.amazon.com/iamv2/home?#/roles/details/${aws_iam_role.valtix_inventory_role.name}"
    cloudtrail      = one([for ct in aws_cloudtrail.valtix_cloudtrail : "https://console.aws.amazon.com/cloudtrail/home?#/trails/${ct.arn}"])
    s3_bucket       = one([for bkt in aws_s3_bucket.valtix_s3_bucket : "https://s3.console.aws.amazon.com/s3/buckets/${bkt.id}"])
  }
}
