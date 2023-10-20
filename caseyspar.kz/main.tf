###############################################################################
# Main
#

## Modules and Outputs ========================================================
module "artifacts" { # -------------------------------------------------------- S3: Artifacts.
  source      = "./modules/artifacts"
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

module "forward_zones" { # ---------------------------------------------------- Forward zones.
  source        = "./modules/forward_zones"
  root_domain   = var.root_domain
  forward_zones = var.forward_zones
}

output "forward_zones_zone_data" {
  description = "Zone data for Cloudflare forward zones."
  value       = module.forward_zones.forward_zones
  sensitive   = false
}

module "api" { # -------------------------------------------------------------- API.
  source      = "./modules/api_gateway"
  root_domain = var.root_domain
  subdomain   = "api.${var.root_domain}"
}

output "api_gateway_fqdn" {
  description = "FQDN of the root API path."
  value       = module.api.aws_api_gateway_fqdn
  sensitive   = false
}

output "aws_api_gateway_id" {
  description = "ID of the AWS API gateway."
  value       = module.api.aws_api_gateway_id
  sensitive   = false
}

output "api_gateway_root_resource_id" {
  description = "ID of the API gateway root resource."
  value       = module.api.aws_api_gateway_root_resource_id
  sensitive   = false
}

output "api_gateway_arn" {
  description = "ARN of the API gateway."
  value       = module.api.aws_api_gateway_arn
  sensitive   = true
}

output "api_gateway_execution_arn" {
  description = "ARN of the API gateway."
  value       = module.api.aws_api_gateway_execution_arn
  sensitive   = true
}

output "api_acm_certificate_id" {
  description = "ID of the ACM certificate for the API domain."
  value       = module.api.aws_acm_certificate_id
  sensitive   = false
}

output "api_acm_certificate_arn" {
  description = "ARN of the ACM certificate for the API domain."
  value       = module.api.aws_acm_certificate_arn
  sensitive   = true
}

module "ecr" { # -------------------------------------------------------------- ECR.
  source      = "./modules/ecr"
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
  source                       = "./modules/www"
  root_domain                  = var.root_domain
  subdomain                    = "www.${var.root_domain}"
  artifact_bucket_id           = module.artifacts.s3_bucket_id
  api_gateway_id               = module.api.aws_api_gateway_id
  api_gateway_root_resource_id = module.api.aws_api_gateway_root_resource_id
  api_gateway_execution_arn    = module.api.aws_api_gateway_execution_arn
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

output "www_api_gateway_deployment_execution_arn" {
  description = "Execution ARN of the AWS API deployment for the contact page."
  value       = module.www.aws_api_gateway_deployment_execution_arn
  sensitive   = true
}

output "www_api_gateway_deployment_invoke_url" {
  description = "Invocation URL of the AWS API deployment for the contact page."
  value       = module.www.aws_api_gateway_deployment_invoke_url
  sensitive   = false
}

output "www_api_gateway_source_arn" {
  description = "Source ARN of API GW calls to Lambda."
  value       = module.www.aws_api_gateway_source_arn
  sensitive   = true
}
