####################################################################################################
# AWS S3
#

# WWW static site bucket.
#
resource "aws_s3_bucket" "www_site" {
  bucket        = local.subdomain
  force_destroy = true
  tags = merge(
    {
      service = "s3"
    },
    local.common_tags
  )
}

resource "aws_s3_bucket_website_configuration" "www_site" {
  bucket = aws_s3_bucket.www_site.id

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
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
    aws_s3_bucket_public_access_block.www_site
  ]
}

resource "aws_s3_bucket_policy" "www_site" {
  bucket = aws_s3_bucket.www_site.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          aws_s3_bucket.www_site.arn,
          "${aws_s3_bucket.www_site.arn}/*",
        ]
      },
    ]
  })
}

# Root redirect bucket.
#
resource "aws_s3_bucket" "web_root" {
  bucket        = var.root_domain
  force_destroy = true
  tags = merge(
    {
      service = "s3"
    },
    local.common_tags
  )
}

resource "aws_s3_bucket_website_configuration" "web_root" {
  bucket = aws_s3_bucket.web_root.id

  redirect_all_requests_to {
    host_name = aws_s3_bucket.www_site.id
  }
}

