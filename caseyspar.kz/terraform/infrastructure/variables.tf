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
  default     = {}
  description = "Tags to be applied to all infrastructure resources."
  type        = map(any)
  sensitive   = false
}
