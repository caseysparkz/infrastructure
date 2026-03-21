################################################################################
# Main
#

locals {
  environment = "prod"
  project     = "caseysparkz"
  application = "store"
  namespace   = "${local.environment}-${local.project}-${local.application}"
  common_tags = {
    Application = local.application
    Domain      = "${random_uuid.this.id}.caseysparkz.com"
    Environment = local.environment
    ManagedBy   = "terraform"
    Namespace   = local.namespace
    Project     = local.project
  }
}

# Data =========================================================================
data "aws_iam_policy_document" "s3_read_write" {
  statement {
    sid       = "ListBucket"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.this.arn]
  }

  statement { #tfsec:ignore:aws-iam-no-policy-wildcards
    sid = "ReadWriteObjects"
    actions = ["s3:*Object"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }
}

data "aws_iam_policy_document" "enforce_group_mfa" {
  statement { #tfsec:ignore:aws-iam-no-policy-wildcards
    sid       = "AllowAllActionsIfMfaPresent"
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}

# Resources ====================================================================
resource "random_uuid" "this" {}

resource "aws_resourcegroups_group" "this" {
  name = "${local.namespace}-rg"
  tags = { Name = "${local.namespace}-rg" }

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"]
      TagFilters = [
        for key, value in local.common_tags :
        {
          Key    = key
          Values = [value]
        }
      ]
    })
  }
}

# S3 ---------------------------------------------------------------------------
resource "aws_s3_bucket" "this" { #tfsec:ignore:aws-s3-enable-bucket-logging
  bucket        = random_uuid.this.id
  force_destroy = false
  tags          = { Name = "${local.namespace}-s3-bucket" }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule { object_ownership = "BucketOwnerPreferred" }
}

resource "aws_s3_bucket_acl" "this" {
  depends_on = [aws_s3_bucket_ownership_controls.this]
  bucket     = aws_s3_bucket.this.id
  acl        = "private"
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_id
      sse_algorithm     = "aws:kms"
    }
  }
}

# IAM --------------------------------------------------------------------------
resource "aws_iam_user" "this" {
  name = "${local.namespace}-iam-user"
  tags = { Name = "${local.namespace}-iam-user" }
}

resource "aws_iam_group" "this" { name = "${local.namespace}-iam-group" }

resource "aws_iam_group_policy" "enforce_mfa" {
  name   = "${local.namespace}-iam-group-policy-enforcemfa"
  group  = aws_iam_group.this.name
  policy = data.aws_iam_policy_document.enforce_group_mfa.json
}

resource "aws_iam_group_policy" "s3_readwrite" {
  name   = "${local.namespace}-iam-group-policy-s3readwrite"
  group  = aws_iam_group.this.name
  policy = data.aws_iam_policy_document.s3_read_write.json
}

resource "aws_iam_group_membership" "this" {
  name  = "${local.namespace}-iam-group-membership"
  group = aws_iam_group.this.name
  users = [aws_iam_user.this.name]
}

resource "aws_iam_access_key" "this" {
  user   = aws_iam_user.this.name
  status = "Active"
}

# Outputs ======================================================================
output "aws_s3_bucket_url" {
  description = "URL of the S3 bucket."
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "aws_access_key_id" {
  description = "AWS access key ID and secret key for the S3 user."
  value       = aws_iam_access_key.this.id
  sensitive   = false
}

output "aws_secret_access_key" {
  description = "AWS access key ID and secret key for the S3 user."
  value       = aws_iam_access_key.this.secret
  sensitive   = true
}
