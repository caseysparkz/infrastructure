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
module "infrastructure" { #
  source      = "./infrastructure"
  root_domain = var.root_domain
  common_tags = local.common_tags
}

## ECR ========================================================================
module "ecr" { #                                                                Module.
  source               = "./ecr"
  ecr_repository_names = var.ecr_repository_names
}

output "ecr_registry_url" { #                                                   Outputs.
  description = "URLs of ECR repository for root domain."
  value       = "${module.ecr.ecr_registry_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
  sensitive   = false
}

output "ecr_registry_repository_urls" {
  description = "List of URLs for all deployed ECR repositories."
  value       = module.ecr.ecr_registry_repository_urls
  sensitive   = false
}

/*
## WWW ========================================================================
module "www" { #                                                                Module.
  source              = "./www"
  root_domain         = var.root_domain
  artifact_bucket_uri = module.infrastructure.aws_s3_bucket_name_artifacts
  artifact_zip_name   = "www_contact_form.zip"
  function_name       = "contact_form"
  common_tags         = local.common_tags
}

output "www_s3_bucket_endpoint" { #                                             Outputs.
  description = "Endpoint of the www.{root_domain} S3 bucket."
  value       = module.www.aws_s3_bucket_endpoint
  sensitive = false
}

output "www_s3_bucket_uri" {
  description = "URI of the www.{root_domain} S3 bucket (as expected by the AWS CLI)."
  value       = "s3://${module.www.aws_s3_bucket_uri}"
  sensitive = false
}

## EKS ========================================================================
module "eks" { #                                                                Module.
  source = "./eks"
}

output "eks_sample_output" { #                                                  Outputs.
  description = "Placeholder EKS output.
  value = "eks_sample_output"
  sensitive = false
}
*/
