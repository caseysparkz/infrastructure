###############################################################################
# AWS S3
#
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "${var.root_domain}-tfstate"
  force_destroy = false
  tags = merge(
    {
      service = "s3"
    },
    local.common_tags
  )
}

resource "aws_s3_bucket_ownership_controls" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "terraform_state" {
  depends_on = [aws_s3_bucket_ownership_controls.terraform_state]
  bucket     = aws_s3_bucket.terraform_state.id
  acl        = "private"
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_state.key_id
      sse_algorithm     = "aws:kms"
    }
  }
}
