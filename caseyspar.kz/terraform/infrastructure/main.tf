###############################################################################
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

###############################################################################
# Modules
#

## Artifacts ==================================================================
module "artifacts" {
  source      = "./artifacts_s3"
  root_domain = var.root_domain
  common_tags = local.common_tags
}

output "aws_s3_bucket_name_artifacts" {
  description = "FQDN of the S3 bucket (as expected by the Terraform backend config)."
  value       = module.artifacts.aws_s3_bucket_name
}

output "artifact_aws_s3_bucket_uri_artifacts" {
  description = "URI of the S3 bucket (as expected by the AWS CLI)."
  value       = "s3://${module.artifacts.aws_s3_bucket_name}"
}

output "aws_kms_key_artifacts" {
  description = "ID of the KMS key used to encrypt domain artifacts."
  value       = module.artifacts.aws_kms_key
}

output "aws_kms_key_alias_artifacts" {
  description = "Alias of the KMS key used to encrypt Terraform domain artifacts."
  value       = module.artifacts.aws_kms_key_alias
}
