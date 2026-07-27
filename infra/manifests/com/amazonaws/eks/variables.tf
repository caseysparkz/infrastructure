################################################################################
# Variables
#

variable "vpc_cidr" {
  description = "CIDR of the AWS VPC."
  type        = string
  sensitive   = false
  default     = "10.254.0.0/16"

  validation {
    condition     = cidrsubnet(var.vpc_cidr, 0, 0) == var.vpc_cidr
    error_message = "Invalid VPC CIDR."
  }
}
