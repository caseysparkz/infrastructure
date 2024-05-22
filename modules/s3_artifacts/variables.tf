###############################################################################
# Variables
#

## Misc. ======================================================================
variable "root_domain" {
  type        = string
  description = "Root domain of the deployed infrastructure."
  sensitive   = false
}
