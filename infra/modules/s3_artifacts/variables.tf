################################################################################
# Variables
#

# Misc. ========================================================================
variable "root_domain" {
  description = "Root domain of the deployed infrastructure."
  type        = string
  sensitive   = false
}

variable "kms_key_arn" {
  description = "ID of the AWS KMS key used to encrypt S3 artifacts."
  type        = string
  sensitive   = false
}

variable "s3_bucket_versioning_status" {
  description = "S3 bucket versioning status ['Enabled'||'Disabled']."
  type        = string
  sensitive   = false
  default     = "Enabled"

  validation {
    condition     = contains(["Enabled", "Disabled"], var.s3_bucket_versioning_status)
    error_message = "Invalid option for var.s3_bucket_versioning_status."
  }
}
