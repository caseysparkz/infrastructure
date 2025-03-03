###############################################################################
# Variables
#

variable "root_domain" {
  type        = string
  description = "Root domain of the deployed infrastructure."
  sensitive   = false
}

variable "forward_zones" {
  type        = list(string)
  description = "List of subdomains to forward to root."
  sensitive   = false
}

variable "cloudflare_comment" {
  type        = string
  description = "Default comment to apply to all Cloudflare resources."
  sensitive   = false
  default     = "Terraform managed."
}
