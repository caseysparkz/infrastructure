###############################################################################
# Cloudflare
#

## Locals =====================================================================
locals {
  cloudflare_comment = "Terraform managed."
  cloudflare_zone_id = data.cloudflare_zone.root_domain.id
  dmarc_policy = { #                                                            Parsed to string.
    p     = "reject"
    sp    = "reject"
    adkim = "s"
    aspf  = "s"
    fo    = 1
    pct   = 5
    rua   = "mailto:dmarc_rua@${var.root_domain}"
    ruf   = "mailto:dmarc_ruf@${var.root_domain}"
  }
}

## Data =======================================================================
data "cloudflare_zone" "root_domain" { #                                        Root zone.
  name = var.root_domain
}

## Resources ==================================================================
resource "cloudflare_zone_settings_override" "root_zone" { #                    Zone settings.
  zone_id = local.cloudflare_zone_id

  settings {
    always_use_https         = "on"
    automatic_https_rewrites = "on"
    http3                    = "on"
    min_tls_version          = "1.2"
    opportunistic_encryption = "on"
    ssl                      = "flexible"
    tls_1_3                  = "on"
    universal_ssl            = "on"
  }
}

resource "cloudflare_record" "mx" { #                                           MX records.
  for_each        = var.mx_servers
  zone_id         = local.cloudflare_zone_id
  name            = var.root_domain
  value           = each.key
  type            = "MX"
  ttl             = 1
  proxied         = false
  priority        = each.value
  allow_overwrite = true
  comment         = local.cloudflare_comment
}

resource "cloudflare_record" "dkim" { #                                         DKIM records.
  for_each        = var.dkim_records
  zone_id         = local.cloudflare_zone_id
  name            = each.key
  value           = each.value
  type            = "CNAME"
  ttl             = 1
  proxied         = false
  allow_overwrite = true
  comment         = local.cloudflare_comment
}

resource "cloudflare_record" "txt_dmarc" { #                                    DMARC policy.
  zone_id         = local.cloudflare_zone_id
  name            = "_dmarc"
  value           = "v=DMARC1;${join(";", [for k, v in local.dmarc_policy : "${k}=${v}"])}"
  type            = "TXT"
  ttl             = 1
  proxied         = false
  allow_overwrite = true
  comment         = local.cloudflare_comment
}

resource "cloudflare_record" "txt_spf" { #                                      SPF record.
  zone_id         = local.cloudflare_zone_id
  name            = var.root_domain
  value           = "v=spf1 ${join(" ", var.spf_senders)} -all"
  type            = "TXT"
  ttl             = 1
  proxied         = false
  allow_overwrite = true
  comment         = local.cloudflare_comment
}

resource "cloudflare_record" "txt_verification" { #                             Domain verification.
  for_each        = toset(var.verification_records)
  zone_id         = local.cloudflare_zone_id
  name            = var.root_domain
  value           = each.value
  type            = "TXT"
  ttl             = 1
  proxied         = false
  allow_overwrite = true
  comment         = local.cloudflare_comment
}

resource "cloudflare_record" "txt_pka" { #                                      Pubkey records.
  for_each        = var.pka_records
  zone_id         = local.cloudflare_zone_id
  name            = "${each.key}._pka"
  value           = "v=pka1; fpr=${each.value}"
  type            = "TXT"
  ttl             = 1
  proxied         = false
  allow_overwrite = true
  comment         = local.cloudflare_comment
}

## Outputs ====================================================================
output "main_cloudflare_zone_root" {
  description = "Zone data for the root Cloudflare DNS zone."
  value       = data.cloudflare_zone.root_domain
}
