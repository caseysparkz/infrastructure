/* AWS S3 */

// Data ========================================================================
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

// Resources ===================================================================
//// WWW site ------------------------------------------------------------------
resource "aws_s3_bucket" "www_site" { // trivy:ignore:AWS-0089 trivy:ignore:AWS-0090 trivy:ignore:AWS-0132
  bucket        = var.subdomain
  force_destroy = true
  tags          = { Name = var.subdomain }
}

resource "aws_s3_bucket_versioning" "www_site" {
  bucket = aws_s3_bucket.www_site.id

  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "www_site" { // trivy:ignore:AWS-0132
  bucket = aws_s3_bucket.www_site.id

  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_website_configuration" "www_site" {
  bucket = aws_s3_bucket.www_site.id

  index_document { suffix = "index.html" }
  error_document { key = "404.html" }
}

resource "aws_s3_bucket_ownership_controls" "www_site" {
  bucket = aws_s3_bucket.www_site.id

  rule { object_ownership = "BucketOwnerPreferred" }
}

resource "aws_s3_bucket_public_access_block" "www_site" {
  bucket                  = aws_s3_bucket.www_site.id
  block_public_acls       = false // trivy:ignore:AWS-0086
  block_public_policy     = false // trivy:ignore:AWS-0087
  ignore_public_acls      = false // trivy:ignore:AWS-0091
  restrict_public_buckets = false // trivy:ignore:AWS-0093
}

resource "aws_s3_bucket_acl" "www_site" {
  depends_on = [
    aws_s3_bucket_ownership_controls.www_site,
    aws_s3_bucket_public_access_block.www_site,
  ]
  bucket = aws_s3_bucket.www_site.id
  acl    = "public-read" // tfsec:ignore:aws-s3-no-public-access-with-acl
}

resource "aws_s3_bucket_policy" "www_site" {
  bucket = aws_s3_bucket.www_site.id
  policy = data.aws_iam_policy_document.s3_public_read_access.json
}

//// @ -------------------------------------------------------------------------
resource "aws_s3_bucket" "web_root" { // trivy:ignore:AWS-0089 trivy:ignore:AWS-0090 trivy:ignore:AWS-0132
  bucket        = var.root_domain
  force_destroy = true
  tags          = { Name = var.root_domain }
}

resource "aws_s3_bucket_website_configuration" "web_root" {
  bucket = aws_s3_bucket.web_root.id

  redirect_all_requests_to {
    host_name = aws_s3_bucket.www_site.id
    protocol  = "https"
  }
}

resource "aws_s3_bucket_public_access_block" "web_root" {
  bucket                  = aws_s3_bucket.web_root.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "web_root" { // trivy:ignore:AWS-0132
  bucket = aws_s3_bucket.web_root.id

  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

// S3 Lambda artifact ----------------------------------------------------------
resource "aws_s3_object" "lambda_contact_form" {
  bucket      = var.artifact_bucket_id
  key         = basename(data.archive_file.lambda_contact_form.output_path)
  source      = data.archive_file.lambda_contact_form.output_path
  source_hash = filemd5(data.archive_file.lambda_contact_form.output_path)
}

// Outputs =====================================================================
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
