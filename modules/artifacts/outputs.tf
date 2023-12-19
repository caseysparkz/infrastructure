###############################################################################
# Outputs
#

output "s3_bucket_id" {
  description = "ID/FQDN of the S3 bucket."
  value       = aws_s3_bucket.artifacts.id
}

output "kms_key_id" {
  description = "ID of the KMS key used to encrypt domain artifacts."
  value       = aws_kms_key.artifacts.key_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key used to encrypt domain artifacts."
  value       = aws_kms_key.artifacts.arn
}

output "kms_key_alias" {
  description = "Alias of the KMS key used to encrypt Terraform domain artifacts."
  value       = aws_kms_alias.artifacts.name
}
