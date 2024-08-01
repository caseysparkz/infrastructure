###############################################################################
# ECR
#
locals {
  ecr_authorization_token = data.aws_ecr_authorization_token.token
  ecr_registry_url        = replace(local.ecr_authorization_token.proxy_endpoint, "https://", "")
}

# Data ========================================================================
data "aws_ecr_authorization_token" "token" {} #                                 ECR token

# Resources ===================================================================
resource "aws_ecr_repository" "ecr" {
  for_each             = toset([for f in fileset(var.docker_compose_dir, "*") : replace(f, "/:.*$/", "")])
  name                 = each.key
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
  tags                 = local.common_tags

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecr.arn
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Outputs =====================================================================
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
