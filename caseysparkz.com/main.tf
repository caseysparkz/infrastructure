###############################################################################
# Main
#

locals {
  common_tags = {
    terraform = true
    domain    = var.root_domain
  }
  dmarc_list = [ # Parsed to string
    { key = "p", value = "reject" },
    { key = "sp", value = "reject" },
    { key = "adkim", value = "s" },
    { key = "aspf", value = "s" },
    { key = "fo", value = 1 },
    { key = "pct", value = 5 },
    { key = "rua", value = "mailto:dmarc_rua@${var.root_domain}" },
    { key = "ruf", value = "mailto:dmarc_ruf@${var.root_domain}" },
  ]
  dmarc_policy = join(";", [for item in local.dmarc_list : "${item.key}=${item.value}"]) # Parse local.dmarc_list
}

## Modules and Outputs ========================================================
module "artifacts" { # -------------------------------------------------------- S3: Artifacts
  source      = "../modules/s3_artifacts"
  root_domain = var.root_domain
  common_tags = local.common_tags
}

output "artifacts_s3_bucket_id" {
  description = "Name of the S3 bucket used to hold artifacts."
  value       = module.artifacts.s3_bucket_id
  sensitive   = false
}

output "artifacts_kms_key_id" {
  description = "KMS key used to encrypt artifacts."
  value       = module.artifacts.kms_key_id
  sensitive   = false
}

output "artifacts_kms_key_arn" {
  description = "KMS key used to encrypt artifacts."
  value       = module.artifacts.kms_key_arn
  sensitive   = true
}

output "artifacts_kms_key_alias" {
  description = "Alias of the KMS key used to encrypt artifacts."
  value       = module.artifacts.kms_key_alias
  sensitive   = false
}

module "www" { # -------------------------------------------------------------- WWW
  source                        = "../modules/hugo_static_site"
  root_domain                   = var.root_domain
  subdomain                     = "www.${var.root_domain}"
  artifact_bucket_id            = module.artifacts.s3_bucket_id
  site_title                    = var.root_domain
  hugo_dir                      = abspath("frontends/www")
  js_contact_form_template_path = abspath("frontends/www/static/js/contactForm.js.tftpl")
  common_tags                   = local.common_tags
}

output "www_s3_bucket_endpoint" {
  description = "Endpoint of the static site S3 bucket."
  value       = module.www.aws_s3_bucket_endpoint
  sensitive   = false
}

output "www_s3_bucket_id" {
  description = "ID of the static site S3 bucket."
  value       = module.www.aws_s3_bucket_id
  sensitive   = false
}

output "www_aws_lambda_function_invoke_url" {
  description = "Invocation URL for the contact form Lambda function."
  value       = module.www.aws_lambda_function_invoke_url
  sensitive   = false
}

module "proton" {
  source             = "../modules/proton_domain"
  cloudflare_zone_id = local.cloudflare_zone_id
  cloudflare_comment = local.cloudflare_comment
  domain             = var.root_domain
  txt_verification   = "protonmail-verification=af8861ffc1961e58bfc47af155f91c468923c49d"
  spf_record         = "v=spf1 include:_spf.protonmail.ch -all"
  dmarc_policy       = local.dmarc_policy
  dkim_record = {
    "protonmail._domainkey"  = "protonmail.domainkey.d56wvdqzbgjl657p6p37duzymskqqisyreca5lrft72j35tshomoq.domains.proton.ch."
    "protonmail2._domainkey" = "protonmail2.domainkey.d56wvdqzbgjl657p6p37duzymskqqisyreca5lrft72j35tshomoq.domains.proton.ch."
    "protonmail3._domainkey" = "protonmail3.domainkey.d56wvdqzbgjl657p6p37duzymskqqisyreca5lrft72j35tshomoq.domains.proton.ch."
  }
}

module "proton_home" {
  source             = "../modules/proton_domain"
  cloudflare_zone_id = local.cloudflare_zone_id
  cloudflare_comment = local.cloudflare_comment
  domain             = "home.${var.root_domain}"
  txt_verification   = "protonmail-verification=9b021e210af76144b6841abcc22762b764d6636b"
  mx_record          = {}
  spf_record         = "v=spf1 include:_spf.protonmail.ch -all"
  dmarc_policy       = local.dmarc_policy
  dkim_record = {
    "protonmail._domainkey"  = "protonmail.domainkey.d4gc64isfcsi5uij7rmm2nggww7zvww7zvmtyw5guqxefeghia2wq.domains.proton.ch."
    "protonmail2._domainkey" = "protonmail2.domainkey.d4gc64isfcsi5uij7rmm2nggww7zvww7zvmtyw5guqxefeghia2wq.domains.proton.ch."
    "protonmail3._domainkey" = "protonmail3.domainkey.d4gc64isfcsi5uij7rmm2nggww7zvww7zvmtyw5guqxefeghia2wq.domains.proton.ch."
  }
}

module "ecr" { # -------------------------------------------------------------- ECR
  source             = "../modules/ecr"
  root_domain        = var.root_domain
  docker_compose_dir = abspath("./docker_compose")
  common_tags        = local.common_tags
}

output "ecr_registry_url" {
  description = "URL of the deployed ECR registry."
  value       = module.ecr.ecr_registry_url
  sensitive   = false
}

output "ecr_registry_repository_urls" {
  description = "List of URLs for the deployed ECR registry repositories."
  value       = module.ecr.ecr_registry_repository_urls
  sensitive   = false
}
