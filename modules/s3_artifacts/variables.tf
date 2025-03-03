###############################################################################
# Variables
#

## Misc. ======================================================================
variable "root_domain" {
  description = "Root domain of the deployed infrastructure."
  type        = string
  sensitive   = false
}

variable "common_tags" {
  description = "Map of common tags to apply to all Terraform resources."
  type        = map(string)
  sensitive   = false
  default     = { terraform = true }
}
