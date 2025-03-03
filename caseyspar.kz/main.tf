###############################################################################
# Main
#

locals {
  common_tags = {
    terraform = true
    domain    = var.root_domain
  }
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

module "forward_zones" { # ---------------------------------------------------- Forward zones
  source             = "../modules/forward_zones"
  root_domain        = var.root_domain
  forward_zones      = var.forward_zones
  cloudflare_comment = local.cloudflare_comment
}

output "forward_zones_zone_data" {
  description = "Zone data for Cloudflare forward zones."
  value       = module.forward_zones.forward_zones
  sensitive   = false
}

module "home_caseyspar_kz" { # ------------------------------------------------ home.caseyspar.kz DNS records
  source          = "../modules/cloudflare_dns_zone"
  zone_id         = local.cloudflare_zone_id
  default_comment = local.cloudflare_comment
  dns_records = [
    {
      name  = "protonmail._domainkey.home"
      value = "protonmail.domainkey.dok2malzbe4elcaifzhg2d6n7z7b63mmmndojsdamrmfzbaro6qfa.domains.proton.ch"
      type  = "CNAME"
    },
    {
      name  = "protonmail2._domainkey.home"
      value = "protonmail2.domainkey.dok2malzbe4elcaifzhg2d6n7z7b63mmmndojsdamrmfzbaro6qfa.domains.proton.ch"
      type  = "CNAME"
    },
    {
      name  = "protonmail3._domainkey.home"
      value = "protonmail3.domainkey.dok2malzbe4elcaifzhg2d6n7z7b63mmmndojsdamrmfzbaro6qfa.domains.proton.ch"
      type  = "CNAME"
    },
    {
      name  = "_dmarc.home"
      value = "v=DMARC1; adkim=s; aspf=s; fo=1; p=reject; pct=5; rua=mailto:dmarc_rua@caseyspar.kz; ruf=mailto:dmarc_ruf@caseyspar.kz; sp=reject"
      type  = "TXT"
    },
    {
      name  = "home"
      value = "v=spf1 include:_spf.protonmail.ch -all"
      type  = "TXT"
    },
    {
      name  = "home"
      value = "protonmail-verification=6ac5ecc9a46a3c1e0ee4138867f9d7041f404f25"
      type  = "TXT"
    },
  ]
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
