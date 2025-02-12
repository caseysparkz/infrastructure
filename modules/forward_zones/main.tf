###############################################################################
# Main
#
locals {
  zone_map = { #                                                                Like {"fqdn": "zone_id"}.
    for zone in data.cloudflare_zones.forward_zones :
    zone.result[0].name => zone.result[0].id
  }
}

# Data ========================================================================
data "cloudflare_zones" "root_zone" { name = var.root_domain }

data "cloudflare_zones" "forward_zones" {
  for_each = toset(var.forward_zones)
  name     = each.key
}

# Resources ===================================================================
resource "cloudflare_dns_record" "cname" {
  for_each = local.zone_map
  zone_id  = each.value
  name     = each.key
  content  = var.root_domain
  type     = "CNAME"
  ttl      = 1
  proxied  = true
  comment  = var.cloudflare_comment
}

resource "cloudflare_dns_record" "cname_www" {
  for_each = local.zone_map
  zone_id  = each.value
  name     = "www.${each.key}"
  content  = var.root_domain
  type     = "CNAME"
  ttl      = 1
  proxied  = true
  comment  = var.cloudflare_comment
}

resource "cloudflare_page_rule" "forward_zones" {
  for_each = local.zone_map
  zone_id  = each.value
  target   = "${each.key}/*"
  priority = 1
  status   = "active"
  actions = {
    forwarding_url = {
      url         = "https://${var.root_domain}/"
      status_code = "301"
    }
  }
}

# Outputs =====================================================================
output "forward_zones" {
  description = "Zone data for the Cloudflare forward zones."
  value       = [for zone in data.cloudflare_zones.forward_zones : zone.result[0]]
  sensitive   = false
}
