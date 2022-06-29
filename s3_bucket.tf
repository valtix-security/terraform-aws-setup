locals {
  # if s3 bucket is not provided then don't create. 
  # Use map to make this check and everything else that depends on the s3
  s3_bucket = { for bkt in [var.s3_bucket] : bkt => "dontcare" if bkt != "" }

  # cloud trail is created if var.create_cloud_trail is true and s3_bucket is not ""
  # use the same bucket name as above but with an extra condition
  cloud_trail_s3_bucket = { for bkt in [var.s3_bucket] : bkt => "dontcare" if bkt != "" && var.create_cloud_trail == true }
}

resource "aws_s3_bucket" "valtix_s3_bucket" {
  for_each      = local.s3_bucket
  bucket        = each.key
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  for_each = local.s3_bucket
  bucket   = aws_s3_bucket.valtix_s3_bucket[each.key].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  for_each = local.s3_bucket
  bucket   = aws_s3_bucket.valtix_s3_bucket[each.key].id
  rule {
    id     = "Delete Objects after ${var.object_duration} days"
    status = "Enabled"
    expiration {
      days = var.object_duration
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  for_each                = local.s3_bucket
  bucket                  = aws_s3_bucket.valtix_s3_bucket[each.key].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "valtix_s3_bucket_policy" {
  for_each = local.s3_bucket
  bucket   = aws_s3_bucket.valtix_s3_bucket[each.key].id
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
        Resource = aws_s3_bucket.valtix_s3_bucket[each.key].arn,
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      },
      {
        Action   = "s3:PutObject",
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.valtix_s3_bucket[each.key].arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
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
        Resource = aws_s3_bucket.valtix_s3_bucket[each.key].arn,
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
      },
      {
        Action   = "s3:PutObject",
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.valtix_s3_bucket[each.key].arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
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
  for_each = local.s3_bucket
  bucket   = aws_s3_bucket.valtix_s3_bucket[each.key].id
  queue {
    queue_arn = "arn:aws:sqs:${data.aws_region.current.name}:${var.controller_aws_account_number}:inventory_logs_queue_${var.deployment_name}_${data.aws_region.current.name}"
    events    = ["s3:ObjectCreated:*"]
  }
  # to make the destroy go in sequence, otherwise you get "conflicting operation" errors
  depends_on = [
    aws_s3_bucket_policy.valtix_s3_bucket_policy
  ]
}
