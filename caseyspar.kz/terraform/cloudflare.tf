###############################################################################
# Cloudflare Root DNS 
#
## Locals =====================================================================
locals {
  dmarc_policy = { #                                                            {key: value} (parsed to string)
    p     = "reject"
    adkim = "s"
    aspf  = "s"
    fo    = 1
    pct   = 5
    rua   = "mailto:dmarc_rua@${var.root_domain}"
    ruf   = "mailto:dmarc_ruf@${var.root_domain}"
  }
  forward_zones = toset([for zone in data.cloudflare_zone.forward_zones : zone.id])
}

## Data =======================================================================
data "cloudflare_zone" "root_domain" { name = var.root_domain } #               Root zone.

data "cloudflare_zone" "forward_zones" { #                                      Forward zones.
  for_each = toset(var.forward_zones)
  name     = each.value
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
  comment         = "Terraform-managed"
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
  comment         = "Terraform-managed."
}

resource "cloudflare_record" "txt_dmarc" { #                                    DMARC policy.
  zone_id         = data.cloudflare_zone.root_domain.id
  name            = "_dmarc"
  value           = "v=DMARC1; ${join("; ", [for k, v in local.dmarc_policy : "${k}=${v}"])}"
  type            = "TXT"
  ttl             = 1
  proxied         = false
  allow_overwrite = true
  comment         = "Terraform-managed."
}

resource "cloudflare_record" "txt_spf" { #                                      SPF record.
  zone_id         = data.cloudflare_zone.root_domain.id
  name            = var.root_domain
  value           = "v=spf1 ${join(" ", var.spf_senders)} -all"
  type            = "TXT"
  ttl             = 1
  proxied         = false
  allow_overwrite = true
  comment         = "Terraform-managed."
}

resource "cloudflare_record" "txt_verification" { #                             Domain verifications.
  for_each        = toset(var.verification_records)
  zone_id         = data.cloudflare_zone.root_domain.id
  name            = var.root_domain
  value           = each.value
  type            = "TXT"
  ttl             = 1
  proxied         = false
  allow_overwrite = true
  comment         = "Terraform-managed."
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
  comment         = "Terraform-managed."
}

/*
## Rules ======================================================================
resource "cloudflare_ruleset" "redirect_forward_zone" {
  for_each    = local.forward_zones
  zone_id     = each.value
  name        = "redirects"
  description = "Redirects ruleset"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  rules {
    action      = "redirect"
    expression  = "(http.request.uri.path matches \"^*\")"
    description = "Redirect request to ${var.root_domain}."
    enabled     = true

    action_parameters {
      from_value {
        status_code           = 301
        preserve_query_string = false

        target_url {
          value = "https://${var.root_domain}/"
        }
      }
    }
  }
}
*/

## Outputs ====================================================================
output "cloudflare_zone_root" {
  description = "ID of the domain Cloudflare DNS zone."
  value       = data.cloudflare_zone.root_domain
}

output "cloudflare_zones_forward" {
  description = "List of forward zone IDs."
  value       = data.cloudflare_zone.forward_zones
}
