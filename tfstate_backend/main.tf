###############################################################################
# Main
#

locals {
  common_tags = {
    terraform = true
    service   = "tfstate"
  }
}
