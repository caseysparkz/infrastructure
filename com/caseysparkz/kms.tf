################################################################################
# AWS KMS
#
# KMS key for encrypting all domain artifacts.

# Resources ====================================================================
resource "aws_kms_key" "this" {
  description             = "KMS key to encrypt domain artifacts/S3 bucket objects."
  deletion_window_in_days = 30
  tags                    = { Service = "kms" }
}

# Outputs ======================================================================
output "aws_kms_key_id" {
  description = "ID of the KMS key used to encrypt all domain artifacts."
  value       = aws_kms_key.this.key_id
  sensitive   = false
}

output "aws_kms_key_arn" {
  description = "ARN of the KMS key used to encrypt all domain artifacts."
  value       = aws_kms_key.this.arn
  sensitive   = false
}
