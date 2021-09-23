resource "aws_s3_bucket" "valtix_s3_bucket" {
  bucket        = var.s3_bucket
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  lifecycle_rule {
    id = "Delete Objects after ${var.object_duration} days"
    enabled = true
    expiration {
      days = var.object_duration
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.valtix_s3_bucket.id
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "valtix_s3_bucket_policy" {
  bucket = aws_s3_bucket.valtix_s3_bucket.id
  depends_on = [
    aws_s3_bucket_public_access_block.block_public_access
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "valtix-bucket-policy"
    Statement = [
      {
        Action   = "s3:GetBucketAcl",
        Effect   = "Allow",
        Resource = aws_s3_bucket.valtix_s3_bucket.arn,
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      },
      {
        Action   = "s3:PutObject",
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.valtix_s3_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Action   = "s3:GetBucketAcl",
        Effect   = "Allow",
        Resource = aws_s3_bucket.valtix_s3_bucket.arn,
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
      },
      {
        Action   = "s3:PutObject",
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.valtix_s3_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        },
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_notification" "valtix_s3_bucket_notification" {
  bucket = aws_s3_bucket.valtix_s3_bucket.id

  queue {
    queue_arn = "arn:aws:sqs:${var.region}:${var.controller_aws_account_number}:inventory_logs_queue_${var.deployment_name}_${var.region}"
    events    = ["s3:ObjectCreated:*"]
  }

  # to make the destroy go in sequence, otherwise you get "conflicting operation" errors
  depends_on = [
    aws_s3_bucket_policy.valtix_s3_bucket_policy
  ]
}
