########################################################################################################################
# Outputs
#

output "ecr_registry_id" {
  description = "List of URLs for deployed ECR registries."
  value = [
    for v in aws_ecr_repository.ecr : v.registry_id
  ][0]
}
