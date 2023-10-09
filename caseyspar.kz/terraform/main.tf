########################################################################################################################
# Locals
#

locals {
  common_tags = {
    domain    = var.root_domain
    terraform = true
  }
}

########################################################################################################################
# Modules and Their Outputs
#

## Infrastructure =============================================================
module "infrastructure" { #                                                     Module.
  source      = "./infrastructure"
  root_domain = var.root_domain
  common_tags = local.common_tags
}

output "infrastructure_artifacts_s3_bucket_name" { #                            Outputs.
  description = "Name of the S3 bucket used to hold artifacts."
  value       = module.infrastructure.artifacts_s3_bucket_name
  sensitive   = false
}

output "infrastructure_artifacts_s3_bucket_URI" {
  description = "URI of the S3 bucket used to hold artifacts."
  value       = module.infrastructure.artifacts_s3_bucket_uri
  sensitive   = false
}

output "infrastructure_artifacts_kms_key" {
  description = "KMS key used to encrypt artifacts."
  value       = module.infrastructure.artifacts_kms_key
  sensitive   = false
}

output "infrastructure_artifacts_kms_key_alias" {
  description = "Alias of the KMS key used to encrypt artifacts."
  value       = module.infrastructure.artifacts_kms_key_alias
  sensitive   = false
}

## ECR ========================================================================
module "ecr" { #                                                                Module.
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
