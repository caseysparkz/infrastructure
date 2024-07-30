###############################################################################
# Variables
#

## AWS ========================================================================
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

variable "aws_access_key" {
  type        = string
  description = "AWS access key for the deployment user."
  sensitive   = true
}

variable "aws_secret_key" {
  type        = string
  description = "Secret key corresponding to the AWS access key."
  sensitive   = true
}

## Cloudflare =================================================================
variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare account ID."
  sensitive   = false
}

variable "cloudflare_api_token" {
  type        = string
  description = "API token for Cloudflare authentication."
  sensitive   = true
}

## Misc. ======================================================================
variable "root_domain" {
  type        = string
  description = "Root domain of Terraform infrastructure."
  default     = "lazzykoffa.com"
  sensitive   = false
}

variable "site_title" {
  type        = string
  description = "Title of the website."
  default     = "lazzykoffa.com"
  sensitive   = false
}
