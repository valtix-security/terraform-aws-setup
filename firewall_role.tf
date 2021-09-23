resource "aws_iam_role" "valtix_fw_role" {
  name = "${var.prefix}-firewall-role"
  tags = {
    Name   = "${var.prefix}-firewall-role"
    prefix = var.prefix
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy" "valtix_fw_policy" {
  name = "${var.prefix}_fw_policy"
  role = aws_iam_role.valtix_fw_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:s3:::*/*"
      },
      {
        Action = [
          "kms:Decrypt"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# for instances to use the role, an instance profile must be created and
# instance profile name used on the instance's iam role
# however on the firewall iam role text box you can provide the role
# name or the arn of either the role or the instance profile
resource "aws_iam_instance_profile" "valtix_fw_role" {
  name = "${var.prefix}-firewall-role"
  role = aws_iam_role.valtix_fw_role.name
}
