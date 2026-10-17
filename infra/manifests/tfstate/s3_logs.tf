/* S3: Log Bucket */

locals {
  logs_access_prefix     = "s3-access/"
  logs_cloudtrail_prefix = "cloudtrail"
  cloudtrail_name        = "${local.namespace}-cloudtrail"
  cloudtrail_arn         = "arn:aws:cloudtrail:${data.aws_region.this.region}:${data.aws_caller_identity.this.account_id}:trail/${local.cloudtrail_name}"
}

// Data ========================================================================
data "aws_iam_policy_document" "s3_logs" {
  statement { // DenyInsecureTransport
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.logs.arn,
      "${aws_s3_bucket.logs.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement { // AllowS3ServerAccessLogDelivery
    sid       = "AllowS3ServerAccessLogDelivery"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.logs.arn}/s3-access/*"]

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.this.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.this.account_id]
    }
  }

  statement { // AllowCloudTrailAclCheck
    sid       = "AllowCloudTrailAclCheck"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.logs.arn]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.cloudtrail_arn]
    }
  }

  statement { // AllowCloudTrailLogDelivery
    sid       = "AllowCloudTrailLogDelivery"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.logs.arn}/${local.logs_cloudtrail_prefix}/AWSLogs/${data.aws_caller_identity.this.account_id}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.cloudtrail_arn]
    }
  }

  statement { // DenyLogTamperingByPrincipals
    // Only AWS service principals may write logs; no IAM principal may write or delete them.
    sid       = "DenyLogTamperingByPrincipals"
    effect    = "Deny"
    resources = ["${aws_s3_bucket.logs.arn}/*"]
    actions = [
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:PutObject",
      "s3:RestoreObject",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:PrincipalIsAWSService"
      values   = ["false"]
    }
  }

  statement { // DenyLogReadsToNonAdmins
    sid       = "DenyLogReadsToNonAdmins"
    effect    = "Deny"
    resources = ["${aws_s3_bucket.logs.arn}/*"]
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "ArnNotEquals"
      variable = "aws:PrincipalArn"
      values   = var.admin_principal_arns
    }
  }

  statement { // DenyLogListingToNonStatePrincipals
    // State principals need s3:ListBucket for HeadBucket, which `terraform plan` uses to refresh aws_s3_bucket.logs.
    sid       = "DenyLogListingToNonStatePrincipals"
    effect    = "Deny"
    resources = [aws_s3_bucket.logs.arn]
    actions = [
      "s3:ListBucket",
      "s3:ListBucketVersions",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "ArnNotEquals"
      variable = "aws:PrincipalArn"
      values   = distinct(concat(var.admin_principal_arns, local.state_principal_arns))
    }
  }

  statement { // DenyBucketAdministrationToNonAdmins
    sid       = "DenyBucketAdministrationToNonAdmins"
    effect    = "Deny"
    resources = [aws_s3_bucket.logs.arn]
    actions   = local.s3_admin_actions

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "ArnNotEquals"
      variable = "aws:PrincipalArn"
      values   = var.admin_principal_arns
    }
  }
}

// Resources ===================================================================
resource "aws_s3_bucket" "logs" { // trivy:ignore:AWS-0089 trivy:ignore:AWS-0163 (log bucket does not log itself)
  bucket        = "${local.namespace}-s3-bucket-logs"
  force_destroy = false
  tags          = { Name = "${local.namespace}-s3-bucket-logs" }
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule { object_ownership = "BucketOwnerEnforced" }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "logs" {
  depends_on = [aws_s3_bucket_public_access_block.logs]
  bucket     = aws_s3_bucket.logs.id
  policy     = data.aws_iam_policy_document.s3_logs.json
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" { // trivy:ignore:AWS-0132 (S3 access log delivery requires SSE-S3)
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "rule_01"
    status = "Enabled"

    filter {} // All objects

    transition { // Transition to infrequent access after one month
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition { // Transition to Glacier after three months
      days          = 90
      storage_class = "GLACIER"
    }

    expiration { days = 365 } // Delete logs after one year

    noncurrent_version_expiration { noncurrent_days = 30 }

    abort_incomplete_multipart_upload { days_after_initiation = 7 }
  }
}

resource "aws_cloudtrail" "this" { // trivy:ignore:AWS-0014 trivy:ignore:AWS-0015 trivy:ignore:AWS-0162
  depends_on                    = [aws_s3_bucket_policy.logs]
  name                          = local.cloudtrail_name
  s3_bucket_name                = aws_s3_bucket.logs.id
  s3_key_prefix                 = local.logs_cloudtrail_prefix
  enable_log_file_validation    = true
  include_global_service_events = false // S3 and KMS events are regional
  is_multi_region_trail         = false // State bucket and KMS key are single-region
  tags                          = { Name = local.cloudtrail_name }

  advanced_event_selector { // Bucket and KMS key administration, and KMS key usage
    name = "Management events"

    field_selector {
      field  = "eventCategory"
      equals = ["Management"]
    }
  }

  advanced_event_selector { // State object reads and writes
    name = "State bucket object events"

    field_selector {
      field  = "eventCategory"
      equals = ["Data"]
    }

    field_selector {
      field  = "resources.type"
      equals = ["AWS::S3::Object"]
    }

    field_selector {
      field       = "resources.ARN"
      starts_with = ["${aws_s3_bucket.this.arn}/"]
    }
  }
}

// Outputs =====================================================================
output "aws_s3_logs_bucket_name" {
  description = "Name of the S3 bucket holding tfstate access logs and CloudTrail logs."
  value       = aws_s3_bucket.logs.id
}
