################################################################################
# Cloudflare
#

# Locals =======================================================================
locals {
  cloudflare_comment = "Terraform managed."
  cloudflare_zone_id = data.cloudflare_zones.root_domain.result[0].id
  cloudflare_zone_settings = {
    always_use_https         = "on"
    automatic_https_rewrites = "on"
    http3                    = "on"
    min_tls_version          = "1.2"
    opportunistic_encryption = "on"
    ssl                      = "flexible"
    tls_1_3                  = "on"
  }
}

# Data =========================================================================
data "cloudflare_zones" "root_domain" { name = var.root_domain }

# Resources ====================================================================
resource "cloudflare_zone_setting" "root_zone" {
  for_each   = local.cloudflare_zone_settings
  zone_id    = local.cloudflare_zone_id
  setting_id = each.key
  value      = each.value
}

resource "cloudflare_dns_record" "txt" {
  for_each = var.txt_records
  zone_id  = local.cloudflare_zone_id
  name     = each.value
  content  = each.key
  type     = "TXT"
  ttl      = 1
  proxied  = false
  comment  = local.cloudflare_comment
}

resource "cloudflare_dns_record" "pka" {
  for_each = var.pka_records
  zone_id  = local.cloudflare_zone_id
  name     = "${each.key}._pka"
  content  = "v=pka1; fpr=${each.value}"
  type     = "TXT"
  ttl      = 1
  proxied  = false
  comment  = local.cloudflare_comment
}
