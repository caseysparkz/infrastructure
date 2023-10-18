###############################################################################
# Cloudflare
#

## Locals =====================================================================
locals {
  cloudflare_comment = "Terraform managed."
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
resource "cloudflare_record" "mx" { #                                           MX records.
  for_each        = var.mx_servers
  zone_id         = data.cloudflare_zone.root_domain.id
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
  zone_id         = data.cloudflare_zone.root_domain.id
  name            = each.key
  value           = each.value
  type            = "CNAME"
  ttl             = 1
  proxied         = false
  allow_overwrite = true
  comment         = local.cloudflare_comment
}

resource "cloudflare_record" "txt_dmarc" { #                                    DMARC policy.
  zone_id         = data.cloudflare_zone.root_domain.id
  name            = "_dmarc"
  value           = "v=DMARC1;${join(";", [for k, v in local.dmarc_policy : "${k}=${v}"])}"
  type            = "TXT"
  ttl             = 1
  proxied         = false
  allow_overwrite = true
  comment         = local.cloudflare_comment
}

resource "cloudflare_record" "txt_spf" { #                                      SPF record.
  zone_id         = data.cloudflare_zone.root_domain.id
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
  zone_id         = data.cloudflare_zone.root_domain.id
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
  zone_id         = data.cloudflare_zone.root_domain.id
  name            = "${each.key}._pka"
  value           = "v=pka1; fpr=${each.value}"
  type            = "TXT"
  ttl             = 1
  proxied         = false
  allow_overwrite = true
  comment         = local.cloudflare_comment
}

## Outputs ====================================================================
output "cloudflare_zone_root" {
  description = "ID of the domain Cloudflare DNS zone."
  value       = data.cloudflare_zone.root_domain
}
