################################################################################
# Variables
#

# AWS ==========================================================================
variable "aws_region" {
  type        = string
  description = "AWS region to deploy to."
  sensitive   = false
  default     = "us-west-2"

  validation {
    condition     = contains(["us-east-1", "us-west-2"], var.aws_region)
    error_message = "AWS region not in ['us-east-1', 'us-west-2']."
  }
}

# Misc. ========================================================================
variable "root_domain" {
  type        = string
  description = "Root domain of Terraform infrastructure."
  sensitive   = false
  default     = "caseysparkz.com"
}
