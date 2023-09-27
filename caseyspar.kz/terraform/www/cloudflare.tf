########################################################################################################################
# Cloudflare
#

data "cloudflare_zones" "domain" {
  filter {
    name = var.root_domain
  }
}

resource "cloudflare_record" "www_cname" {
  zone_id         = data.cloudflare_zones.domain.zones[0].id
  name            = local.subdomain
  value           = aws_s3_bucket_website_configuration.www_site.website_endpoint
  type            = "CNAME"
  ttl             = 1
  proxied         = true
  allow_overwrite = true
  comment         = "S3 bucket for ${var.root_domain} static pages."
}

resource "cloudflare_record" "root_cname" {
  zone_id         = data.cloudflare_zones.domain.zones[0].id
  name            = var.root_domain
  value           = local.subdomain
  type            = "CNAME"
  ttl             = 1
  proxied         = true
  allow_overwrite = true
  comment         = "S3 bucket for ${local.subdomain} static pages."
}
