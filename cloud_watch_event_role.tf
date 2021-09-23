resource "aws_iam_role" "valtix_cloudwatch_event_role" {
  name = "${var.prefix}-inventory-role"

  tags = {
    Name   = "${var.prefix}-inventory-role"
    prefix = var.prefix
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy" "valtix_cloudwatch_event_policy" {
  name = "${var.prefix}-cloudwatch-event-policy"
  role = aws_iam_role.valtix_cloudwatch_event_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "events:PutEvents",
        Effect = "Allow",
        Resource = [
          "arn:aws:events:*:${var.controller_aws_account_number}:event-bus/default"
        ]
      }
    ]
  })
}
