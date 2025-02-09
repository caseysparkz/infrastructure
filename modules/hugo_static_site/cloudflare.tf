###############################################################################
# Cloudflare
#
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

# Data ========================================================================
data "cloudflare_zone" "domain" { name = var.root_domain } #                    Root zone.

# Resources ===================================================================
resource "cloudflare_record" "root_cname" { #                                   Redirect bucket.
  zone_id         = data.cloudflare_zone.domain.id
  name            = var.root_domain
  content         = aws_s3_bucket_website_configuration.web_root.website_endpoint
  type            = "CNAME"
  ttl             = 1
  proxied         = true
  allow_overwrite = true
  comment         = local.cloudflare_comment
}

resource "cloudflare_record" "subdomain_cname" { #                              Site bucket.
  zone_id         = data.cloudflare_zone.domain.id
  name            = var.subdomain
  content         = aws_s3_bucket_website_configuration.www_site.website_endpoint
  type            = "CNAME"
  ttl             = 1
  proxied         = true
  allow_overwrite = true
  comment         = local.cloudflare_comment
}

resource "cloudflare_record" "ses_verification" { #                             Verify ownership.
  zone_id         = data.cloudflare_zone.domain.id
  name            = "_amazonses.${aws_ses_domain_identity.root_domain.id}"
  content         = aws_ses_domain_identity.root_domain.verification_token
  type            = "TXT"
  ttl             = 1
  proxied         = false
  allow_overwrite = true
  comment         = local.cloudflare_comment
}

resource "cloudflare_record" "subdomain_mx" { #                                 MX record.
  zone_id         = data.cloudflare_zone.domain.id
  name            = var.subdomain
  content         = "feedback-smtp.${data.aws_region.current.name}.amazonses.com"
  type            = "MX"
  ttl             = 1
  priority        = 10
  proxied         = false
  allow_overwrite = true
  comment         = local.cloudflare_comment
}

resource "cloudflare_record" "subdomain_spf" { #                                SPF record.
  zone_id         = data.cloudflare_zone.domain.id
  name            = var.subdomain
  content         = "v=spf1 include:amazonses.com -all"
  type            = "TXT"
  ttl             = 1
  proxied         = false
  allow_overwrite = true
  comment         = local.cloudflare_comment
}

resource "cloudflare_record" "dkim" { #                                         DKIM record.
  count           = 3
  zone_id         = data.cloudflare_zone.domain.id
  name            = "${element(aws_ses_domain_dkim.root_domain.dkim_tokens, count.index)}._domainkey.${var.root_domain}"
  content         = "${element(aws_ses_domain_dkim.root_domain.dkim_tokens, count.index)}.dkim.amazonses.com"
  type            = "CNAME"
  ttl             = 1
  proxied         = false
  allow_overwrite = true
  comment         = local.cloudflare_comment
}
