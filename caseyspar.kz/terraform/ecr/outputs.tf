########################################################################################################################
# Outputs
#

output "ecr_registry_id" {
  description = "Registry ID of the deployed ECR registry."
  value       = [for v in aws_ecr_repository.ecr : v.registry_id][0]
  sensitive   = false
}

output "ecr_registry_repository_urls" {
  description = "List of URLs for all deployed ECR repositories."
  value       = [for v in aws_ecr_repository.ecr : v.repository_url]
  sensitive   = false
}
