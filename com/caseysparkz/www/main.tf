################################################################################
# Main
#

locals {
  environment = "prod"
  project     = "caseysparkz"
  application = "www"
  namespace   = "${local.environment}-${local.project}-${local.application}"
  common_tags = {
    ManagedBy = "terraform"
    Domain    = "www.${var.root_domain}"
    Namespace = local.namespace
  }
  aws_kms_key_arn = "arn:aws:kms:${var.aws_region}:${local.aws_account_id}:key/${var.aws_kms_key_id}"
}

# Resources ====================================================================
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

# Modules ======================================================================
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
  hugo_dir                      = abspath("frontend")
  js_contact_form_template_path = abspath("frontend/static/js/contactForm.js.tftpl")
  common_tags                   = local.common_tags
  aws_kms_key_arn               = local.aws_kms_key_arn
}
