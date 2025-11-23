###############################################################################
# Variables
#

# AWS =========================================================================
variable "aws_region" {
  description = "AWS region to deploy to."
  type        = string
  sensitive   = false
  default     = "us-west-2"

  validation {
    condition     = contains(["us-east-1", "us-west-2"], var.aws_region)
    error_message = "AWS region not in ['us-east-1', 'us-west-2']."
  }
}

# Misc. =======================================================================
variable "bucket_name" {
  description = "Name of the AWS bucket to create."
  type        = string
  sensitive   = false
  default     = "com.caseysparkz.tfstate"
}
