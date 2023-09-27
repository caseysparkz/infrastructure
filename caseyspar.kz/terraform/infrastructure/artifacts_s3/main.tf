########################################################################################################################
# Locals
#

locals {
  common_tags = merge(
    {
      terraform      = true
      cli_access     = true
      console_access = true
    },
    var.common_tags
  )
}
