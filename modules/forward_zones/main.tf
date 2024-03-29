###############################################################################
# Main
#
locals {
  zone_map = { #                                                                Like {"fqdn": "zone_id"}.
    for zone, data in data.cloudflare_zone.forward_zones : zone => data.id
  }
}

# Data ========================================================================
data "cloudflare_zone" "root_zone" {
  name = var.root_domain
}

data "cloudflare_zone" "forward_zones" {
  for_each = toset(var.forward_zones)
  name     = each.key
}

# Resources ===================================================================
resource "cloudflare_record" "cname" {
  for_each        = local.zone_map
  zone_id         = each.value
  name            = each.key
  value           = var.root_domain
  type            = "CNAME"
  ttl             = 1
  proxied         = true
  allow_overwrite = true
  comment         = var.cloudflare_comment
}

resource "cloudflare_record" "cname_www" {
  for_each        = local.zone_map
  zone_id         = each.value
  name            = "www.${each.key}"
  value           = var.root_domain
  type            = "CNAME"
  ttl             = 1
  proxied         = true
  allow_overwrite = true
  comment         = var.cloudflare_comment
}

resource "cloudflare_page_rule" "forward_zones" {
  for_each = local.zone_map
  zone_id  = each.value
  target   = "${each.key}/*"
  priority = 1

  actions {
    forwarding_url {
      url         = "https://${var.root_domain}/"
      status_code = "301"
    }
  }
}

# Outputs =====================================================================
output "forward_zones" {
  description = "Zone data for the Cloudflare forward zones."
  value       = data.cloudflare_zone.forward_zones
  sensitive   = false
}
