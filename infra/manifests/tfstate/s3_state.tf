/* S3: Terraform State */

locals {
  s3_read_actions = [
    "s3:GetObject",
    "s3:GetObjectVersion",
    "s3:ListBucket",
    "s3:ListBucketVersions",
  ]
  s3_lock_actions = [
    "s3:DeleteObject",
    "s3:PutObject",
  ]
  s3_write_actions = [
    "s3:DeleteObject",
    "s3:DeleteObjectVersion",
    "s3:PutObject",
    "s3:RestoreObject",
  ]
  s3_admin_actions = [
    "s3:DeleteBucket",
    "s3:DeleteBucketPolicy",
    "s3:PutBucketAcl",
    "s3:PutBucketLogging",
    "s3:PutBucketObjectLockConfiguration",
    "s3:PutBucketOwnershipControls",
    "s3:PutBucketPolicy",
    "s3:PutBucketPublicAccessBlock",
    "s3:PutBucketTagging",
    "s3:PutBucketVersioning",
    "s3:PutEncryptionConfiguration",
    "s3:PutLifecycleConfiguration",
    "s3:PutReplicationConfiguration",
  ]
}

// Data ========================================================================
data "aws_iam_policy_document" "s3_bucket" {
  statement { // DenyInsecureTransport
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
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

  statement { // DenyStateReadsToNonReaders
    sid    = "DenyStateReadsToNonReaders"
    effect = "Deny"
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]
    actions = local.s3_read_actions

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "ArnNotEquals"
      variable = "aws:PrincipalArn"
      values   = local.state_principal_arns
    }
  }

  statement { // DenyLockWritesToNonReaders
    sid       = "DenyLockWritesToNonReaders"
    effect    = "Deny"
    resources = ["${aws_s3_bucket.this.arn}/*.tflock"]
    actions   = local.s3_lock_actions

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "ArnNotEquals"
      variable = "aws:PrincipalArn"
      values   = local.state_principal_arns
    }
  }

  statement { // DenyStateWritesToNonWriters
    sid           = "DenyStateWritesToNonWriters"
    effect        = "Deny"
    not_resources = ["${aws_s3_bucket.this.arn}/*.tflock"]
    actions       = local.s3_write_actions

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "ArnNotEquals"
      variable = "aws:PrincipalArn"
      values   = var.writer_principal_arns
    }
  }

  statement { // DenyBucketAdministrationToNonAdmins
    sid       = "DenyBucketAdministrationToNonAdmins"
    effect    = "Deny"
    resources = [aws_s3_bucket.this.arn]
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
resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name // trivy:ignore:AWS-0320
  force_destroy = false
  tags          = { Name = "${local.namespace}-s3-bucket" }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_logging" "this" {
  depends_on    = [aws_s3_bucket_policy.logs]
  bucket        = aws_s3_bucket.this.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = local.logs_access_prefix

  target_object_key_format {
    partitioned_prefix { partition_date_source = "EventTime" }
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule { object_ownership = "BucketOwnerEnforced" }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "this" {
  depends_on = [aws_s3_bucket_public_access_block.this]
  bucket     = aws_s3_bucket.this.id
  policy     = data.aws_iam_policy_document.s3_bucket.json
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

// Outputs =====================================================================
output "aws_s3_bucket_name" {
  description = "FQDN of the S3 bucket (as expected by the Terraform backend config)."
  value       = aws_s3_bucket.this.id
}

output "aws_s3_bucket_uri" {
  description = "URI of the S3 bucket (as expected by the AWS CLI)."
  value       = "s3://${aws_s3_bucket.this.id}/"
}
