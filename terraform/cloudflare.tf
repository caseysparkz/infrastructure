resource "cloudflare_record" "root" { #                                         Root domain (CNAME)
  zone_id         = var.cloudflare_zone_id
  name            = "@"
  type            = "CNAME"
  value           = "www.${var.root_domain}" #                                  www CNAME for @
  proxied         = true
  allow_overwrite = true
}

resource "cloudflare_record" "cloud" { #                                        cloud (A)
  zone_id         = var.cloudflare_zone_id
  name            = "cloud"
  type            = "CNAME"
  value           = aws_s3_bucket.cloud.bucket_regional_domain_name
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "ecr" { #                                          ecr (CNAME)
  zone_id         = var.cloudflare_zone_id
  name            = "ecr"
  type            = "CNAME"
  value           = "${aws_ecr_repository.alpine_base.registry_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "keys" { #                                         keys (A)
  zone_id         = var.cloudflare_zone_id
  name            = "keys"
  type            = "CNAME"
  value           = aws_s3_bucket.keys.bucket_regional_domain_name
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "www" { #                                          www (CNAME)
  zone_id         = var.cloudflare_zone_id
  name            = "www"
  type            = "CNAME"
  value           = "caseysparkz.netlify.app"
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "mx" { #                                           Primary (MX)
  zone_id         = var.cloudflare_zone_id
  name            = var.root_domain
  type            = "MX"
  value           = "mail.protonmail.ch"
  priority        = 10
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "mx1" { #                                          Failover 1 (MX)
  zone_id         = var.cloudflare_zone_id
  name            = var.root_domain
  type            = "MX"
  value           = "mailsec.protonmail.ch"
  priority        = 20
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "spf" { #                                          SPF (TXT)
  zone_id         = var.cloudflare_zone_id
  name            = var.root_domain
  type            = "TXT"
  value           = "v=spf1 include:_spf.protonmail.ch mx ~all"
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "_dmarc" { #                                       DMARC (TXT)
  zone_id = var.cloudflare_zone_id
  name    = "_dmarc"
  type    = "TXT"
  value   = "v=DMARC1; p=reject; sp=reject; rua=mailto:admin@${var.root_domain}; ruf=mailto:dmarc@${var.root_domain}; fo=1; pct=5;"

  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "keybase_site_verification" { #                    Keybase verification. (TXT)
  zone_id         = var.cloudflare_zone_id
  name            = var.root_domain
  type            = "TXT"
  value           = "keybase-site-verification=8MXkrublC6Bg6NPBvHAwmK12v1FledQETZS1ux_oi0A"
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "protonmail_verification" { #                      Google verification. (TXT)
  zone_id         = var.cloudflare_zone_id
  name            = var.root_domain
  type            = "TXT"
  value           = "protonmail-verification=fe3be76ae32c8b2a12ec3e6348d6a598e4e4a4f3"
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "himself_pka" { #                                  PKA record. (TXT)
  zone_id         = var.cloudflare_zone_id
  name            = "himself._pka"
  type            = "TXT"
  value           = "v=pka1;fpr=${var.admin_pgp_fingerprint};uri=https://keys.${var.root_domain}/public.asc"
  proxied         = false
  allow_overwrite = true
}
