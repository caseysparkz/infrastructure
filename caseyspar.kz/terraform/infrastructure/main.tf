###############################################################################
# Main
#

## Locals =====================================================================
locals {
  common_tags = merge(
    {
      service = "infrastructure"
    },
    var.common_tags
  )
}

## Modules and Outputs
module "artifacts" { # -------------------------------------------------------- Artifacts module.
  source      = "./artifacts"
  root_domain = var.root_domain
  common_tags = local.common_tags
}

output "artifacts_s3_bucket_id" { # ------------------------------------------- Artifacts outputs.
  description = "FQDN of the S3 bucket (as expected by the Terraform backend config)."
  value       = module.artifacts.aws_s3_bucket_id
}

output "artifacts_s3_bucket_uri" {
  description = "URI of the S3 bucket (as expected by the AWS CLI)."
  value       = module.artifacts.aws_s3_bucket_uri
}

output "artifacts_kms_key_id" {
  description = "ID of the KMS key used to encrypt domain artifacts."
  value       = module.artifacts.aws_kms_key_id
  sensitive   = false
}

output "artifacts_kms_key_arn" {
  description = "ARN of the KMS key used to encrypt domain artifacts."
  value       = module.artifacts.aws_kms_key_arn
  sensitive   = false
}

output "artifacts_kms_key_alias" {
  description = "Alias of the KMS key used to encrypt Terraform domain artifacts."
  value       = module.artifacts.aws_kms_key_alias
  sensitive   = false
}
