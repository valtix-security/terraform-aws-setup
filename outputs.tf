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

output "z_console_urls" {
  value = {
    controller-role = "https://console.aws.amazon.com/iamv2/home?#/roles/details/${aws_iam_role.valtix_controller_role.name}"
    firewall-role   = "https://console.aws.amazon.com/iamv2/home?#/roles/details/${aws_iam_role.firewall_role.name}"
    inventory-role  = "https://console.aws.amazon.com/iamv2/home?#/roles/details/${aws_iam_role.inventory_role.name}"
  }
}
