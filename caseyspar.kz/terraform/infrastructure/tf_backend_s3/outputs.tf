output "aws_s3_bucket_name" {
  description = "FQDN of the S3 bucket (as expected by the Terraform backend config)."
  value       = aws_s3_bucket.terraform_state.id
}

output "aws_s3_bucket_uri" {
  description = "URI of the S3 bucket (as expected by the AWS CLI)."
  value       = "s3://${aws_s3_bucket.terraform_state.id}/"
}

output "aws_kms_key" {
  description = "ID of the KMS key used to encrypt Terraform state."
  value       = aws_kms_key.terraform_state.key_id
}

output "aws_kms_key_alias" {
  description = "Alias of the KMS key used to encrypt Terraform state."
  value       = aws_kms_alias.terraform_state.name
}
