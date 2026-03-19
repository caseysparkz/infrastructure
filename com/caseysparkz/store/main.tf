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
data "aws_iam_policy_document" "assume_role" {
  statement {
    sid     = "AllowIamUserAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.this.arn]
    }
  }
}

data "aws_iam_policy_document" "s3_read_write" {
  statement {
    sid       = "ListBucket"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.this.arn]
  }

  statement {
    sid = "ReadWriteObjects"
    actions = [
      "s3:GetObject",
      "s3:DeleteObject",
    ]
    resources = ["${aws_s3_bucket.this.arn}/*"] #tfsec:ignore:aws-iam-no-policy-wildcards
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

resource "aws_iam_role" "this" {
  name               = "${local.namespace}-iam-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = { Name = "${local.namespace}-iam-role" }
}

resource "aws_iam_policy" "this" {
  name   = "${local.namespace}-iam-policy"
  policy = data.aws_iam_policy_document.s3_read_write.json
  tags   = { Name = "${local.namespace}-iam-policy" }
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
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
