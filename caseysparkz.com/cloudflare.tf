###############################################################################
# Cloudflare
#

## Locals =====================================================================
locals {
  cloudflare_comment = "Terraform managed."
  cloudflare_zone_id = data.cloudflare_zones.root_domain.result[0].id
  cloudflare_dmarc_policy = { #                                                 Parsed to string
    p     = "reject"
    sp    = "reject"
    adkim = "s"
    aspf  = "s"
    fo    = 1
    pct   = 5
    rua   = "mailto:dmarc_rua@${var.root_domain}"
    ruf   = "mailto:dmarc_ruf@${var.root_domain}"
  }
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

## Data =======================================================================
data "cloudflare_zones" "root_domain" { name = var.root_domain } #              Root zone

## Resources ==================================================================
resource "cloudflare_zone_setting" "root_zone" {
  for_each   = local.cloudflare_zone_settings
  zone_id    = local.cloudflare_zone_id
  setting_id = each.key
  value      = each.value
}

resource "cloudflare_dns_record" "mx" { #                                       MX records
  for_each = var.mx_servers
  zone_id  = local.cloudflare_zone_id
  name     = var.root_domain
  content  = each.key
  type     = "MX"
  ttl      = 1
  proxied  = false
  priority = each.value
  comment  = local.cloudflare_comment
}

resource "cloudflare_dns_record" "dkim" { #                                     DKIM records
  for_each = var.dkim_records
  zone_id  = local.cloudflare_zone_id
  name     = each.key
  content  = each.value
  type     = "CNAME"
  ttl      = 1
  proxied  = false
  comment  = local.cloudflare_comment
}

resource "cloudflare_dns_record" "dmarc" { #                                    DMARC policy
  zone_id = local.cloudflare_zone_id
  name    = "_dmarc"
  content = "v=DMARC1;${join("; ", [for k, v in local.cloudflare_dmarc_policy : "${k}=${v}"])}"
  type    = "TXT"
  ttl     = 1
  proxied = false
  comment = local.cloudflare_comment
}

resource "cloudflare_dns_record" "spf" { #                                      SPF record
  zone_id = local.cloudflare_zone_id
  name    = var.root_domain
  content = "v=spf1 ${join(" ", var.spf_senders)} -all"
  type    = "TXT"
  ttl     = 1
  proxied = false
  comment = local.cloudflare_comment
}

resource "cloudflare_dns_record" "txt" { #                                      TXT records
  for_each = var.txt_records
  zone_id  = local.cloudflare_zone_id
  name     = each.value
  content  = each.key
  type     = "TXT"
  ttl      = 1
  proxied  = false
  comment  = local.cloudflare_comment
}

resource "cloudflare_dns_record" "pka" { #                                      PKA records
  for_each = var.pka_records
  zone_id  = local.cloudflare_zone_id
  name     = "${each.key}._pka"
  content  = "v=pka1; fpr=${each.value}"
  type     = "TXT"
  ttl      = 1
  proxied  = false
  comment  = local.cloudflare_comment
}
