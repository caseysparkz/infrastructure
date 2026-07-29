###############################################################################
# Variables
#

variable "aws_region" {
  description = "AWS region to deploy resources to."
  type        = string
  sensitive   = false
  default     = "us-west-2"
}
