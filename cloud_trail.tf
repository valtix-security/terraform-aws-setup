resource "aws_cloudtrail" "valtix_cloudtrail" {
  for_each                      = local.s3_bucket
  name                          = "${var.prefix}-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.valtix_s3_bucket[each.key].id
  enable_log_file_validation    = true
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_logging                = true
  depends_on = [
    aws_s3_bucket_policy.valtix_s3_bucket_policy
  ]
  tags = {
    Name   = "${var.prefix}-cloudtrail"
    prefix = var.prefix
  }
}
