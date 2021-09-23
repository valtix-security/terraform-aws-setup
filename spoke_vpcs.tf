data "aws_vpcs" "spoke_vpcs" {
  tags = var.spoke_vpc_tags
}
