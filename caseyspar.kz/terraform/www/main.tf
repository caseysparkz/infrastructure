###############################################################################
# Locals
#
locals {
  common_tags = {
    terraform = true
    domain    = var.root_domain
    service   = "www.${var.root_domain}"
  }
  subdomain = "www.${var.root_domain}"
}
