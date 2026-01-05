################################################################################
# Main
#

locals {
  environment = "prod"
  project     = "caseysparkz"
  application = "ecr"
  namespace   = "${local.environment}-${local.project}-${local.application}"
  common_tags = {
    ManagedBy = "terraform"
    Domain    = var.root_domain
    Namespace = local.namespace
  }
}

# Resources ====================================================================
resource "aws_resourcegroups_group" "this" {
  name = "${local.namespace}-rg"
  tags = { Name = "${local.namespace}-rg" }

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"]
      TagFilters = [
        for key, value in local.common_tags :
        {
          Key    = key
          Values = [value]
        }
      ]
    })
  }
}

# Modules ======================================================================
module "ecr" {
  source             = "../../../modules/ecr"
  root_domain        = var.root_domain
  docker_compose_dir = abspath("./docker_compose")
  aws_kms_key_arn    = "de8cf575-e753-44b5-9331-fa1762775478"
}

# Outputs ======================================================================
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
