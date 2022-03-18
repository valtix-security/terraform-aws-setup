resource "time_sleep" "wait_for_controller_account" {
  depends_on = [
    aws_iam_role.valtix_controller_role
  ]
  create_duration = "15s"
}

resource "valtix_cloud_account" "aws1" {
  depends_on = [
    time_sleep.wait_for_controller_account
  ]
  name                     = var.valtix_aws_cloud_account_name
  csp_type                 = "AWS"
  aws_credentials_type     = "AWS_IAM_ROLE"
  aws_iam_role             = aws_iam_role.valtix_controller_role.arn
  aws_account_number       = data.aws_caller_identity.current.account_id
  aws_iam_role_external_id = valtix_external_id.iam_external_id.external_id
  aws_inventory_iam_role   = aws_iam_role.valtix_inventory_role.arn
  inventory_monitoring {
    regions = var.inventory_regions
  }
}
