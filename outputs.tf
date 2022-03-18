output "valtix_controller_role_arn" {
  value = aws_iam_role.valtix_controller_role.arn
}

output "valtix_inventory_role_arn" {
  value = aws_iam_role.valtix_inventory_role.arn
}

output "valtix_firewall_role_name" {
  value = aws_iam_role.valtix_fw_role.name
}
