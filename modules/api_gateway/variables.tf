###############################################################################
# Variables
#

variable "root_domain" {
  description = "Root domain of the Terraformed infrastructure."
  type        = string
  sensitive   = false
}

variable "subdomain" {
  description = "The subdomain of this Terraform module."
  type        = string
  sensitive   = false
}
