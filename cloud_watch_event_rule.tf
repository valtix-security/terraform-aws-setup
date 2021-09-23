resource "aws_cloudwatch_event_rule" "cloudwatch_rule" {
  name = "${var.prefix}-inventory-rule"
  event_pattern = jsonencode({
    source = [
      "aws.ec2",
      "aws.elasticloadbalancing",
      "aws.apigateway"
    ],
    detail-type = [
      "AWS API Call via CloudTrail",
      "EC2 Instance State-change Notification"
    ]
  })
}

resource "aws_cloudwatch_event_target" "controller_target" {
  rule     = aws_cloudwatch_event_rule.cloudwatch_rule.name
  arn      = "arn:aws:events:${var.region}:${var.controller_aws_account_number}:event-bus/default"
  role_arn = aws_iam_role.valtix_cloudwatch_event_role.arn
}
