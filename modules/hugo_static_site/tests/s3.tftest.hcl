###############################################################################
# AWS S3
#

# Data Objects ================================================================
data "aws_iam_policy_document" "s3_public_read_access" {
  statement {
    sid     = "PublicReadGetObject"
    actions = ["s3:GetObject"]
    resources = [
      aws_s3_bucket.www_site.arn,
      "${aws_s3_bucket.www_site.arn}/*",
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

# Resources ===================================================================
resource "aws_s3_bucket" "www_site" { # --------------------------------------- WWW site.
  bucket        = var.subdomain
  force_destroy = true
  tags          = local.common_tags
}

resource "aws_s3_bucket_website_configuration" "www_site" {
  bucket = aws_s3_bucket.www_site.id

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "404.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "www_site" {
  bucket = aws_s3_bucket.www_site.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "www_site" {
  bucket                  = aws_s3_bucket.www_site.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "www_site" {
  bucket = aws_s3_bucket.www_site.id
  acl    = "public-read"
  depends_on = [
    aws_s3_bucket_ownership_controls.www_site,
    aws_s3_bucket_public_access_block.www_site,
  ]
}

resource "aws_s3_bucket_policy" "www_site" {
  bucket = aws_s3_bucket.www_site.id
  policy = data.aws_iam_policy_document.s3_public_read_access.json
}

resource "aws_s3_bucket" "web_root" { # --------------------------------------- Redirect root.
  bucket        = var.root_domain
  force_destroy = true
  tags          = local.common_tags
}

resource "aws_s3_bucket_website_configuration" "web_root" {
  bucket = aws_s3_bucket.web_root.id

  redirect_all_requests_to {
    host_name = aws_s3_bucket.www_site.id
  }
}

resource "aws_s3_object" "lambda_contact_form" { # ---------------------------- S3 Lambda artifact.
  bucket      = var.artifact_bucket_id
  key         = basename(data.archive_file.lambda_contact_form.output_path)
  source      = data.archive_file.lambda_contact_form.output_path
  source_hash = filemd5(data.archive_file.lambda_contact_form.output_path)
}

# Outputs =====================================================================
output "aws_s3_bucket_endpoint" {
  description = "Bucket endpoint"
  value       = aws_s3_bucket_website_configuration.www_site.website_endpoint
  sensitive   = false
}

output "aws_s3_bucket_id" {
  description = "ID of the S3 bucket (as expected by the AWS CLI)."
  value       = aws_s3_bucket.www_site.id
  sensitive   = false
}
