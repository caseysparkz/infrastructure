################################################################################
# Main
#

# Locals =======================================================================
locals {
  common_tags            = merge({ service = "artifacts" }, var.common_tags)
  reverse_dns_domain_dir = join("-", reverse(split(".", var.root_domain)))
}
