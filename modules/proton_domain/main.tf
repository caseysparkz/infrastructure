###############################################################################
# Main
#
# Author:       Casey Sparks
# Date:         August 04, 2025
# Description:  Create the requisite Cloudflare DNS records.

## Resources ==================================================================
resource "cloudflare_dns_record" "txt_verify" { # Verify
  zone_id = var.cloudflare_zone_id
  name    = var.domain
  content = var.txt_verification
  type    = "TXT"
  ttl     = 1
  proxied = false
  comment = var.cloudflare_comment
}

resource "cloudflare_dns_record" "mx" { # MX
  for_each = var.mx_record
  zone_id  = var.cloudflare_zone_id
  name     = var.domain
  content  = each.key
  type     = "MX"
  ttl      = 1
  proxied  = false
  priority = each.value
  comment  = var.cloudflare_comment
}

resource "cloudflare_dns_record" "txt_spf" { # SPF
  zone_id = var.cloudflare_zone_id
  name    = var.domain
  content = var.spf_record
  type    = "TXT"
  ttl     = 1
  proxied = false
  comment = var.cloudflare_comment
}

resource "cloudflare_dns_record" "cname_dkim" { # DKIM
  for_each = var.dkim_record
  zone_id  = var.cloudflare_zone_id
  name     = "${each.key}.${var.domain}"
  content  = each.value
  type     = "CNAME"
  ttl      = 1
  proxied  = false
  comment  = var.cloudflare_comment
}

resource "cloudflare_dns_record" "txt_dmarc" { # DMARC
  zone_id = var.cloudflare_zone_id
  name    = "_dmarc.${var.domain}"
  content = join("; ", [for k, v in var.dmarc_policy : "${k}=${v}"])
  type    = "TXT"
  ttl     = 1
  proxied = false
  comment = var.cloudflare_comment
}
