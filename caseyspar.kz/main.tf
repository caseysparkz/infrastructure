###############################################################################
# Main
#

locals {
  common_tags = {
    terraform = true
    domain    = var.root_domain
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
