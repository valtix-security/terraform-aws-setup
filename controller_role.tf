resource "aws_iam_role" "valtix_controller_role" {
  name = "${var.prefix}-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          AWS = [
            "arn:aws:iam::${var.controller_aws_account_number}:root"
          ]
        },
        Effect = "Allow",
        Condition = {
          StringEquals = {
            "sts:ExternalId" = valtix_external_id.iam_external_id.external_id
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "valtix_controller_policy" {
  name = "${var.prefix}_controller_policy"
  role = aws_iam_role.valtix_controller_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "acm:DescribeCertificate",
          "acm:ListCertificates",
          "apigateway:GET",
          "ec2:*",
          "elasticloadbalancing:*",
          "events:*",
          "globalaccelerator:*",
          "iam:ListPolicies",
          "iam:ListRoles",
          "iam:ListRoleTags",
          "logs:*",
          "route53resolver:*",
          "servicequotas:GetServiceQuota",
          "s3:ListAllMyBuckets",
          "s3:ListBucket",
          "wafv2:Get*",
          "wafv2:List*",
          "networkmanager:*"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "iam:GetRole",
          "iam:ListRolePolicies",
          "iam:GetRolePolicy"
        ],
        Effect = "Allow",
        Resource = [
          aws_iam_role.valtix_controller_role.arn,
          aws_iam_role.valtix_inventory_role.arn,
          aws_iam_role.valtix_fw_role.arn
        ]
      },
      {
        Action = [
          "iam:PassRole"
        ],
        Effect = "Allow",
        Resource = [
          aws_iam_role.valtix_fw_role.arn,
          aws_iam_role.valtix_inventory_role.arn
        ]
      },
      {
        Action   = "iam:CreateServiceLinkedRole",
        Effect   = "Allow",
        Resource = "arn:aws:iam::*:role/aws-service-role/*"
      },
      {
        Action = [
          "secretsmanager:CreateSecret",
          "secretsmanager:UpdateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue"
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:secretsmanager:*:*:secret:events!*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "s3_get_object" {
  for_each = local.s3_bucket
  name     = "${var.prefix}_s3_get_object"
  role     = aws_iam_role.valtix_controller_role.id
  depends_on = [
    aws_s3_bucket.valtix_s3_bucket
  ]

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject"
        ],
        Effect = "Allow",
        Resource = [
          "${aws_s3_bucket.valtix_s3_bucket[each.key].arn}/*"
        ]
      }
    ]
  })
}
