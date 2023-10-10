###############################################################################
# AWS S3
#

## Locals =====================================================================
locals {
  hugo_dir              = "${path.module}/srv"
  hugo_config_template  = "${local.hugo_dir}/config.yaml.tftpl"
  contact_page_template = "${local.hugo_dir}/content/contact.md.tftpl"
  srv_dir               = "${local.hugo_dir}/public/"
  website_files         = fileset(local.srv_dir, "**")
  mime_types = {
    ".html"        = "text/html"
    ".ico"         = "image/vnd.microsoft.icon"
    ".pdf"         = "application/pdf"
    ".png"         = "image/png"
    ".pub"         = "text/plain"
    ".svg"         = "image/svg+xml"
    ".webmanifest" = "application/json"
    ".webp"        = "image/webp"
    ".xml"         = "text/xml"
  }
}

## Data objects ===============================================================
data "aws_caller_identity" "current" {}

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

## Resources ==================================================================
resource "local_file" "hugo_config" { # --------------------------------------- Local build files.
  filename = replace(local.hugo_config_template, ".tftpl", "")
  content = templatefile(
    local.hugo_config_template,
    {
      "domain" = var.subdomain
      "title"  = var.root_domain
    }
  )
}

resource "local_file" "contact_page" {
  filename = replace(local.contact_page_template, ".tftpl", "")
  content = templatefile(
    local.contact_page_template,
    {
      "contact_form_endpoint"  = local.contact_form_endpoint #                  Defined in main.tf.
      "contact_form_recipient" = "contact_form@${var.root_domain}"
    }
  )
}

resource "null_resource" "compile_pages" {
  depends_on = [
    local_file.hugo_config,
    local_file.contact_page
  ]

  provisioner "local-exec" {
    working_dir = local.hugo_dir
    command     = "hugo"
  }
}

resource "aws_s3_bucket" "www_site" { # --------------------------------------- WWW site.
  bucket        = var.subdomain
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
    aws_s3_bucket_public_access_block.www_site
  ]
}

resource "aws_s3_bucket_policy" "www_site" {
  bucket = aws_s3_bucket.www_site.id
  policy = data.aws_iam_policy_document.s3_public_read_access.json
}

# Works but don't like.
resource "null_resource" "deploy_pages" {
  provisioner "local-exec" {
    command = "aws s3 cp --recursive ${local.srv_dir} s3://${aws_s3_bucket.www_site.id}"
  }
}

/* TODO
resource "aws_s3_object_copy" "www_site" { #                                    Terraform abuse!
  depends_on = [
    null_resource.compile_pages,
    aws_s3_bucket.www_site
  ]
  for_each                     = local.website_files
  bucket                       = aws_s3_bucket.www_site.id
  key                          = each.key
  source                       = "${local.srv_dir}/${each.key}"
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.key), "text/plain")
}
*/

resource "aws_s3_bucket" "web_root" { # --------------------------------------- Redirect root.
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
