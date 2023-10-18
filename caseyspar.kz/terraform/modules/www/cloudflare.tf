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
data "cloudflare_zone" "domain" { #                                             Root zone.
  name = var.root_domain
}

## Resources ==================================================================
resource "cloudflare_record" "subdomain_cname" { #                              Site bucket.
  zone_id         = data.cloudflare_zone.domain.id
  name            = var.subdomain
  value           = aws_s3_bucket_website_configuration.www_site.website_endpoint
  type            = "CNAME"
  ttl             = 1
  proxied         = true
  allow_overwrite = true
  comment         = local.cloudflare_comment
}

resource "cloudflare_record" "root_cname" { #                                   Redirect bucket.
  zone_id         = data.cloudflare_zone.domain.id
  name            = var.root_domain
  value           = aws_s3_bucket_website_configuration.web_root.website_endpoint
  type            = "CNAME"
  ttl             = 1
  proxied         = true
  allow_overwrite = true
  comment         = local.cloudflare_comment
}

resource "cloudflare_record" "ses_verification" { #                             Verify ownership.
  zone_id         = data.cloudflare_zone.domain.id
  name            = "_amazonses.${aws_ses_domain_identity.subdomain.id}"
  value           = aws_ses_domain_identity.subdomain.verification_token
  type            = "TXT"
  ttl             = 1
  proxied         = false
  allow_overwrite = true
  comment         = local.cloudflare_comment
}

resource "cloudflare_record" "subdomain_spf" { #                                SPF record.
  zone_id         = data.cloudflare_zone.domain.id
  name            = var.subdomain
  value           = "v=spf1 include:amazonses.com -all"
  type            = "TXT"
  ttl             = 1
  proxied         = false
  allow_overwrite = true
  comment         = local.cloudflare_comment
}

resource "cloudflare_record" "subdomain_dkim" { #                               DKIM record.
  count           = 3
  zone_id         = data.cloudflare_zone.domain.id
  name            = "${element(aws_ses_domain_dkim.subdomain.dkim_tokens, count.index)}._domainkey.var.subdomain"
  value           = "${element(aws_ses_domain_dkim.subdomain.dkim_tokens, count.index)}.dkim.amazonses.com"
  type            = "CNAME"
  ttl             = 1
  proxied         = false
  allow_overwrite = true
  comment         = local.cloudflare_comment
}

/*
resource "cloudflare_record" "subdomain_dmarc" { #                              DMARC record.
  zone_id         = data.cloudflare_zone.domain.id
  name            = "_dmarc.${var.subdomain}"
  value           = "v=DMARC1;${join(";", [for k, v in local.dmarc_policy : "${k}=${v}"])}"
  type            = "TXT"
  ttl             = 1
  proxied         = false
  allow_overwrite = true
  comment         = local.cloudflare_comment
}
*/
