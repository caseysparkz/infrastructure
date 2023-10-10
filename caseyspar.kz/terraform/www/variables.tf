########################################################################################################################
# Variables.
#

## Lambda =====================================================================
variable "artifact_bucket_id" {
  description = "ID of the S3 bucket in which lambda functions are kept."
  type        = string
  sensitive   = false
}

## Misc. ======================================================================
variable "root_domain" {
  description = "Root domain of Terraform infrastructure."
  type        = string
  sensitive   = false
}

variable "subdomain" {
  description = "Subdomain of Terraform infrastructure."
  type        = string
  sensitive   = false
}

variable "common_tags" {
  default = {
    terraform = true
  }
  description = "Tags common to all infrastructure resources."
  type        = map(any)
  sensitive   = false
}
