###############################################################################
# Variables
#

variable "root_domain" {
  type        = string
  description = "Root domain of the Terraformed infrastructure."
  sensitive   = false
}

variable "subdomain" {
  type        = string
  description = "The subdomain of this Terraform module."
  sensitive   = false
}
