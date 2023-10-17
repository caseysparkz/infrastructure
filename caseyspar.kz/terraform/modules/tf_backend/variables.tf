###############################################################################
# Variables
#

## AWS ========================================================================
variable "aws_region" {
  default     = "us-west-2"
  description = "AWS region to deploy to."
  type        = string
  sensitive   = false

  validation {
    condition     = contains(["us-east-1", "us-west-2"], var.aws_region)
    error_message = "AWS region not in ['us-east-1', 'us-west-2']."
  }
}

variable "aws_access_key" {
  description = "Access key for the AWS IAM account deploying the infrastructure."
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "Secret key corresponding to var.aws_access_key."
  type        = string
  sensitive   = true
}

## Misc. ======================================================================
variable "root_domain" {
  description = "Root domain of Terraform infrastructure."
  type        = string
  sensitive   = false
}
