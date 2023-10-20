###############################################################################
# Variables
#

variable "root_domain" {
  description = "Root domain of the deployed infrastructure."
  type        = string
  sensitive   = false
}

variable "forward_zones" {
  description = "List of subdomains to forward to root."
  type        = list(string)
  sensitive   = false
}
