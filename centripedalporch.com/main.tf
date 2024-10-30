###############################################################################
# Main
#
locals {
  environment = lookup( #                                                       Map workspace > environment.
    {
      default : ""
      production : ""
      staging : "stage"
      development : "dev"
    },
    terraform.workspace,
    "dev"
  )
}

## Modules and Outputs ========================================================
module "artifacts" { # -------------------------------------------------------- S3: Artifacts.
  source      = "../modules/s3_artifacts"
  root_domain = var.root_domain
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

module "home_caseyspar_kz" { # ------------------------------------------------ home subdomin records.
  source  = "../modules/cloudflare_dns_zone"
  zone_id = local.cloudflare_zone_id
  dns_records = [
    {
      name : "protonmail._domainkey.home"
      value : "protonmail.domainkey.dok2malzbe4elcaifzhg2d6n7z7b63mmmndojsdamrmfzbaro6qfa.domains.proton.ch"
      type : "CNAME"
      allow_overwrite : true
    },
    {
      name : "protonmail2._domainkey.home"
      value : "protonmail2.domainkey.dok2malzbe4elcaifzhg2d6n7z7b63mmmndojsdamrmfzbaro6qfa.domains.proton.ch"
      type : "CNAME"
      allow_overwrite : true
    },
    {
      name : "protonmail3._domainkey.home"
      value : "protonmail3.domainkey.dok2malzbe4elcaifzhg2d6n7z7b63mmmndojsdamrmfzbaro6qfa.domains.proton.ch"
      type : "CNAME"
      allow_overwrite : true
    },
    {
      name : "_dmarc.home"
      value : "v=DMARC1; adkim=s; aspf=s; fo=1; p=reject; pct=5; rua=mailto:dmarc_rua@caseyspar.kz; ruf=mailto:dmarc_ruf@caseyspar.kz; sp=reject"
      type : "TXT"
      allow_overwrite : true
    },
    {
      name : "home"
      value : "v=spf1 include:_spf.protonmail.ch -all"
      type : "TXT"
      allow_overwrite : true
    },
    {
      name : "home"
      value : "protonmail-verification=6ac5ecc9a46a3c1e0ee4138867f9d7041f404f25"
      type : "TXT"
      allow_overwrite : true
    },
  ]
  default_comment = local.cloudflare_comment
}

module "www" { # -------------------------------------------------------------- WWW.
  source               = "../modules/hugo_static_site"
  root_domain          = var.root_domain
  subdomain            = "www.${var.root_domain}"
  artifact_bucket_id   = module.artifacts.s3_bucket_id
  site_title           = var.root_domain
  hugo_dir             = abspath("frontends/www")
  turnstile_site_key   = cloudflare_turnstile_widget.captcha.id
  turnstile_secret_key = cloudflare_turnstile_widget.captcha.secret
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