###############################################################################
# Main
#

locals {
  common_tags = merge(var.common_tags, { service = var.subdomain })
  email_headers = {
    default_recipient = "form@${var.root_domain}"
    default_sender    = "form@${var.subdomain}"
  }
  reverse_dns_subdomain_dir = join(".", reverse(split(".", var.subdomain)))
}

# Data =========================================================================
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
