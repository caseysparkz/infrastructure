################################################################################
# Main
#

locals {
  common_tags = {
    Terraform = true
    Domain    = "www.${var.root_domain}"
  }
  aws_kms_key_arn = "arn:aws:kms:${var.aws_region}:${local.aws_account_id}:key/${var.aws_kms_key_id}"
}

# Modules and Outputs ==========================================================
module "artifacts" {
  source      = "../../../modules/s3_artifacts"
  root_domain = var.root_domain
  kms_key_arn = local.aws_kms_key_arn
}

module "www" {
  source                        = "../../../modules/hugo_static_site"
  root_domain                   = var.root_domain
  subdomain                     = "www.${var.root_domain}"
  artifact_bucket_id            = module.artifacts.s3_bucket_id
  site_title                    = var.root_domain
  hugo_dir                      = abspath("frontends/www")
  js_contact_form_template_path = abspath("frontends/www/static/js/contactForm.js.tftpl")
  common_tags                   = local.common_tags
  aws_kms_key_arn               = local.aws_kms_key_arn
}
