resource "cloudflare_record" "caseyspar_kz" { #                                     caseyspar.kz (CNAME)
  zone_id         = var.cloudflare_zone_id
  name            = "@"
  type            = "CNAME"
  value           = "www.${var.root_domain}"
  proxied         = true
  allow_overwrite = true
}

resource "cloudflare_record" "cloud_caseyspar_kz" { #                               cloud.caseyspar.kz (A)
  zone_id         = var.cloudflare_zone_id
  name            = "cloud"
  type            = "CNAME"
  value           = aws_s3_bucket.cloud_caseyspar_kz.bucket_regional_domain_name
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "ecr_caseyspar_kz" { #                                 ecr.caseyspar.kz (CNAME)
  zone_id         = var.cloudflare_zone_id
  name            = "ecr"
  type            = "CNAME"
  value           = "${aws_ecr_repository.alpine_base.registry_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "keys_caseyspar_kz" { #                                keys.caseyspar.kz (A)
  zone_id         = var.cloudflare_zone_id
  name            = "keys"
  type            = "CNAME"
  value           = aws_s3_bucket.keys_caseyspar_kz.bucket_regional_domain_name
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "www_caseyspar_kz" { #                                 www.caseyspar.kz (CNAME)
  zone_id         = var.cloudflare_zone_id
  name            = "www"
  type            = "CNAME"
  value           = "caseysparkz.netlify.app"
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "mx" { #                                               Primary (MX)
  zone_id         = var.cloudflare_zone_id
  name            = var.root_domain
  type            = "MX"
  value           = "aspmx.l.google.com"
  priority        = 1
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "mx1" { #                                              Failover 1 (MX)
  zone_id         = var.cloudflare_zone_id
  name            = var.root_domain
  type            = "MX"
  value           = "alt1.aspmx.l.google.com"
  priority        = 5
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "mx2" { #                                              Failover 2 (MX)
  zone_id         = var.cloudflare_zone_id
  name            = var.root_domain
  type            = "MX"
  value           = "alt2.aspmx.l.google.com"
  priority        = 5
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "mx3" { #                                              Failover 3 (MX)
  zone_id         = var.cloudflare_zone_id
  name            = var.root_domain
  type            = "MX"
  value           = "alt3.aspmx.l.google.com"
  priority        = 10
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "mx4" { #                                              Failover 4 (MX)
  zone_id         = var.cloudflare_zone_id
  name            = var.root_domain
  type            = "MX"
  value           = "alt4.aspmx.l.google.com"
  priority        = 10
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "spf" { #                                              SPF (TXT)
  zone_id         = var.cloudflare_zone_id
  name            = var.root_domain
  type            = "TXT"
  value           = "v=spf1 include:_spf.google.com -all"
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "_dmarc" { #                                           DMARC (TXT)
  zone_id         = var.cloudflare_zone_id
  name            = "_dmarc"
  type            = "TXT"
  value           = "v=DMARC1; p=reject; sp=reject; rua=mailto:admin@${var.root_domain}; ruf=mailto:dmarc@${var.root_domain}; fo=1; pct=5;"
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "keybase_site_verification" { #                        Keybase verification. (TXT)
  zone_id         = var.cloudflare_zone_id
  name            = var.root_domain
  type            = "TXT"
  value           = "keybase-site-verification=fz6Bnb_tsLzfkjlhhFk1owgs0LQV2gLjDKyba_mGejY"
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "google_site_verification" { #                         Google verification. (TXT)
  zone_id         = var.cloudflare_zone_id
  name            = var.root_domain
  type            = "TXT"
  value           = "google-site-verification=FNQjTPVGcuLx5QR1RdNpybd1BFkzCQ9o65rUDfH-88w"
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "google_domainkey" { #                                 Google domain key. (TXT)
  zone_id         = var.cloudflare_zone_id
  name            = "google._domainkey"
  type            = "TXT"
  value           = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvQw8k6bXrWSLtmEGfQgx01HH9YeetKGTj4XE568UsZUl7koxUqyvNgQ7RvfKLps/ylR79nb/AIzPzlcOfApaKPie8dJAFqgdq5sDDEBAqSEtkKe7+FjbgwQFj1+5gMbLQ8lRVpwxXXREDbmM64RQkbFbus2Ou5c4+/+qrUeS8ekR3LMd/+7DGIMq1n52uDn0 S4a3v/PleEkDBrdKK89H97BtPv1s0WxFovAQlYYRjr1IxhhqURkZIqDmvPsjsWf0qY9g3Gnyp1tsFinuq1r5X28f7C86WcnfjwmfiQUh6adZ3mdPrVxwRwAkken5z/xMlRYmkfFqeakaLl+3iYIIxwIDAQAB"
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "himself_pka" { #                                      PKA record. (TXT)
  zone_id         = var.cloudflare_zone_id
  name            = "himself._pka"
  type            = "TXT"
  value           = "v=pka1;fpr=${var.admin_pgp_fingerprint};uri=https://keys.${var.root_domain}/public.asc"
  proxied         = false
  allow_overwrite = true
}
