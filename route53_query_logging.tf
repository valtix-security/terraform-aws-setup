resource "aws_route53_resolver_query_log_config" "valtix_route53_query_logging" {
  name            = "${var.prefix}-route53-logging"
  destination_arn = aws_s3_bucket.valtix_s3_bucket.arn
  depends_on = [
    aws_s3_bucket_policy.valtix_s3_bucket_policy
  ]
}

resource "aws_route53_resolver_query_log_config_association" "spoke_vpc_query_logging" {
  count                        = length(data.aws_vpcs.spoke_vpcs.ids)
  resolver_query_log_config_id = aws_route53_resolver_query_log_config.valtix_route53_query_logging.id
  resource_id                  = tolist(data.aws_vpcs.spoke_vpcs.ids)[count.index]
}