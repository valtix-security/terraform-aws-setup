resource "aws_flow_log" "spoke_vpc_flow_logging" {
  depends_on = [
    aws_s3_bucket_policy.valtix_s3_bucket_policy
  ]
  count                = length(data.aws_vpcs.spoke_vpcs.ids)
  log_destination      = aws_s3_bucket.valtix_s3_bucket.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = tolist(data.aws_vpcs.spoke_vpcs.ids)[count.index]
  log_format           = "$${account-id} $${action} $${az-id} $${bytes} $${dstaddr} $${dstport} $${end} $${flow-direction} $${instance-id} $${interface-id} $${log-status} $${packets} $${pkt-dst-aws-service} $${pkt-dstaddr} $${pkt-src-aws-service} $${pkt-srcaddr} $${protocol} $${region} $${srcaddr} $${srcport} $${start} $${sublocation-id} $${sublocation-type} $${subnet-id} $${tcp-flags} $${traffic-path} $${type} $${version} $${vpc-id}"
}
