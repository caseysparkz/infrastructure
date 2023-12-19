###############################################################################
# Cloudflare
#

locals {
  default_comment = "Terraform-managed"
}

## Data =======================================================================
data "cloudflare_zone" "root_domain" { #                                        Root zone.
  name = var.root_domain
}

## Resources ==================================================================
resource "cloudflare_record" "subdomain" {
  zone_id         = data.cloudflare_zone.root_domain.id
  name            = var.subdomain
  value           = aws_api_gateway_domain_name.subdomain.regional_domain_name
  type            = "CNAME"
  ttl             = 1
  proxied         = false
  priority        = 1
  allow_overwrite = true
  comment         = local.default_comment
}

resource "cloudflare_record" "domain_validation" {
  for_each = {
    for opt in aws_acm_certificate.subdomain.domain_validation_options : opt.domain_name => {
      name   = opt.resource_record_name
      record = opt.resource_record_value
      type   = opt.resource_record_type
    }
  }
  zone_id         = data.cloudflare_zone.root_domain.id
  name            = each.value.name
  value           = each.value.record
  type            = each.value.type
  ttl             = 1
  proxied         = false
  priority        = 1
  allow_overwrite = true
  comment         = local.default_comment
}
