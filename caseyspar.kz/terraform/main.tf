###############################################################################
# Locals
#
locals {
  common_tags = {
    domain    = var.root_domain
    terraform = true
  }
}

###############################################################################
# Modules
#
/*
## Infrastructure =============================================================
module "infrastructure" { #
  source      = "./infrastructure"
  root_domain = var.root_domain
  common_tags = local.common_tags
}

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
}

output "www_s3_bucket_uri" {
  description = "URI of the www.{root_domain} S3 bucket (as expected by the AWS CLI)."
  value       = "s3://${module.www.aws_s3_bucket_uri}"
}

## ECR ========================================================================
module "ecr" { #                                                                Module.
  source      = "./ecr"
  root_domain = var.root_domain
}

output "ecr_repository_url" { #                                                 Outputs.
  description = "URL of ECR repository for root domain."
  value       = module.ecr.ecr_repository_url
}

## EKS ========================================================================
module "eks" { #                                                                Module.
  source = "./eks"
}

output "eks_sample_output" { #                                                  Outputs.
  description = "Placeholder EKS output.
  value = "eks_sample_output"
}
*/
