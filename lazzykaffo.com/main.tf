###############################################################################
# Main
#

locals {
  common_tags = {
    service = "www.${var.root_domain}"
  }
}

# Data ========================================================================
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
