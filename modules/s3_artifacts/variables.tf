###############################################################################
# Variables
#

## Misc. ======================================================================
variable "root_domain" {
  description = "Root domain of the deployed infrastructure."
  type        = string
  sensitive   = false
}
