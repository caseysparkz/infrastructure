###############################################################################
# Cloudflare
#

## Locals =====================================================================
locals {
  cloudflare_comment = "Terraform managed."
  cloudflare_zone_id = data.cloudflare_zone.root_domain.id
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

resource "cloudflare_record" "root_cname" { #                                   Redirect bucket.
  zone_id         = data.cloudflare_zone.root_domain.id
  name            = var.root_domain
  value           = aws_s3_bucket_website_configuration.web_root.website_endpoint
  type            = "CNAME"
  ttl             = 1
  proxied         = true
  allow_overwrite = true
  comment         = local.cloudflare_comment
}

resource "cloudflare_record" "subdomain_cname" { #                              Site bucket.
  zone_id         = data.cloudflare_zone.root_domain.id
  name            = "www.${var.root_domain}"
  value           = aws_s3_bucket_website_configuration.www_site.website_endpoint
  type            = "CNAME"
  ttl             = 1
  proxied         = true
  allow_overwrite = true
  comment         = local.cloudflare_comment
}

## Outputs ====================================================================
output "main_cloudflare_zone_root" {
  description = "Zone data for the root Cloudflare DNS zone."
  value       = data.cloudflare_zone.root_domain
}
