###############################################################################
# Main
#

## Locals =====================================================================
locals {
  common_tags = {
    terraform      = true
    cli_access     = true
    console_access = true
    service        = "artifacts"
  }
}
