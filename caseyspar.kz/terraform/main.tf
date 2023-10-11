###############################################################################
# Main
#

## Locals =====================================================================
locals {
  common_tags = {
    domain    = var.root_domain
    terraform = true
  }
}

## Modules and Outputs ========================================================
module "infrastructure" { # --------------------------------------------------- Infrastructure.
  source      = "./infrastructure"
  root_domain = var.root_domain
  common_tags = local.common_tags
}

output "infrastructure_artifacts_s3_bucket_id" {
  description = "Name of the S3 bucket used to hold artifacts."
  value       = module.infrastructure.artifacts_s3_bucket_id
  sensitive   = false
}

output "infrastructure_artifacts_s3_bucket_uri" {
  description = "URI of the S3 bucket used to hold artifacts."
  value       = module.infrastructure.artifacts_s3_bucket_uri
  sensitive   = false
}

output "infrastructure_artifacts_kms_key_id" {
  description = "KMS key used to encrypt artifacts."
  value       = module.infrastructure.artifacts_kms_key_id
  sensitive   = false
}

output "infrastructure_artifacts_kms_key_arn" {
  description = "KMS key used to encrypt artifacts."
  value       = module.infrastructure.artifacts_kms_key_arn
  sensitive   = false
}

output "infrastructure_artifacts_kms_key_alias" {
  description = "Alias of the KMS key used to encrypt artifacts."
  value       = module.infrastructure.artifacts_kms_key_alias
  sensitive   = false
}

module "ecr" { # -------------------------------------------------------------- ECR.
  source      = "./ecr"
  root_domain = var.root_domain
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

module "www" { # -------------------------------------------------------------- WWW.
  source             = "./www"
  root_domain        = var.root_domain
  subdomain          = "www.${var.root_domain}"
  artifact_bucket_id = module.infrastructure.artifacts_s3_bucket_id
  #artifact_bucket_kms_key_arn = module.infrastructure.artifacts_kms_key_arn
  common_tags = local.common_tags
}

output "www_s3_bucket_endpoint" {
  description = "Endpoint of the www.{root_domain} S3 bucket."
  value       = module.www.aws_s3_bucket_endpoint
  sensitive   = false
}

output "www_s3_bucket_uri" {
  description = "URI of the www.{root_domain} S3 bucket (as expected by the AWS CLI)."
  value       = module.www.aws_s3_bucket_uri
  sensitive   = false
}

output "www_contact_form_uri" {
  description = "URI of the www subdomain contact form page."
  value       = module.www.aws_apigateway_contact_form_uri
  sensitive   = false
}
