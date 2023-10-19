###############################################################################
# AWS S3
#

# Resources ===================================================================
resource "aws_s3_bucket" "api" {
  bucket        = var.subdomain
  force_destroy = true
  tags          = local.common_tags
}

resource "aws_s3_bucket_ownership_controls" "api" {
  bucket = aws_s3_bucket.api.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "api" {
  depends_on = [
    aws_s3_bucket_ownership_controls.api,
    aws_s3_bucket_public_access_block.api
  ]
  bucket = aws_s3_bucket.api.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "api" {
  bucket                  = aws_s3_bucket.api.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
