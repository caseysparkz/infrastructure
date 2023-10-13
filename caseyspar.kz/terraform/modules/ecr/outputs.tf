###############################################################################
# Outputs
#

output "ecr_registry_url" {
  description = "URL of the deployed ECR registry."
  value       = replace(data.aws_ecr_authorization_token.token.proxy_endpoint, "https://", "")
  sensitive   = false
}

output "ecr_registry_repository_urls" {
  description = "List of URLs for deployed ECR registries."
  value       = [for v in aws_ecr_repository.ecr : v.repository_url]
  sensitive   = false
}
