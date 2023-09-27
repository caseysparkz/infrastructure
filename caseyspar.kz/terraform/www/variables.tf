########################################################################################################################
# Variables.
#

## Lambda =====================================================================
variable "artifact_bucket_uri" {
  default     = "domain-artifacts"
  description = "S3 URI of the bucket in which the function is kept."
  type        = string
  sensitive   = false
}

variable "artifact_zip_name" {
  description = "Name of the ZIPfile (S3 key) containing the Lambda function."
  type        = string
  sensitive   = false
}

variable "function_name" {
  default     = "send_mail"
  description = ""
  type        = string
  sensitive   = false
}

## Misc. ======================================================================
variable "root_domain" {
  default     = "caseyspar.kz"
  description = "Root domain of Terraform infrastructure."
  type        = string
  sensitive   = false
}

variable "common_tags" {
  default     = { terraform = true }
  description = "Tags common to all infrastructure resources."
  type        = map(any)
  sensitive   = false
}
