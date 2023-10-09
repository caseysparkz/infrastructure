########################################################################################################################
# Locals
#

locals {
  common_tags = merge(
    {
      service = "infrastructure"
    },
    var.common_tags
  )
}

########################################################################################################################
# Modules
#

## Artifacts ==================================================================
module "artifacts" {
  source      = "./artifacts"
  root_domain = var.root_domain
  common_tags = local.common_tags
}

########################################################################################################################
# Outputs
#

output "artifacts_s3_bucket_name" {
  description = "FQDN of the S3 bucket (as expected by the Terraform backend config)."
  value       = module.artifacts.aws_s3_bucket_name
}

output "artifacts_s3_bucket_uri" {
  description = "URI of the S3 bucket (as expected by the AWS CLI)."
  value       = "s3://${module.artifacts.aws_s3_bucket_name}"
}

output "artifacts_kms_key" {
  description = "ID of the KMS key used to encrypt domain artifacts."
  value       = module.artifacts.aws_kms_key
}

output "artifacts_kms_key_alias" {
  description = "Alias of the KMS key used to encrypt Terraform domain artifacts."
  value       = module.artifacts.aws_kms_key_alias
}
