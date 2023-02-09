resource "cloudflare_record" "caseyspar_kz" {
  zone_id         = var.cloudflare_zone_id
  name            = "@"
  type            = "CNAME"
  value           = "www.caseyspar.kz"
  proxied         = true
  allow_overwrite = true
}

resource "cloudflare_record" "cloud_caseyspar_kz" {
  zone_id         = var.cloudflare_zone_id
  name            = "cloud"
  type            = "CNAME"
  value           = "cloud-caseyspar-kz.s3.amazonaws.com"
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "keys_caseyspar_kz" {
  zone_id         = var.cloudflare_zone_id
  name            = "keys"
  type            = "CNAME"
  value           = "keys.caseyspar.kz.s3-website-us-west-1.amazonaws.com"
  proxied         = true
  allow_overwrite = true
}

resource "cloudflare_record" "vpn_caseyspar_kz" {
  zone_id         = var.cloudflare_zone_id
  name            = "vpn"
  type            = "A"
  value           = "35.89.207.9"
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "www_caseyspar_kz" {
  zone_id         = var.cloudflare_zone_id
  name            = "www"
  type            = "CNAME"
  value           = "caseysparkz.netlify.app"
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "mx" {
  zone_id         = var.cloudflare_zone_id
  name            = var.root_domain
  type            = "MX"
  value           = "aspmx.l.google.com"
  priority        = 1
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "mx1" {
  zone_id         = var.cloudflare_zone_id
  name            = var.root_domain
  type            = "MX"
  value           = "alt1.aspmx.l.google.com"
  priority        = 5
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "mx2" {
  zone_id         = var.cloudflare_zone_id
  name            = var.root_domain
  type            = "MX"
  value           = "alt2.aspmx.l.google.com"
  priority        = 5
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "mx3" {
  zone_id         = var.cloudflare_zone_id
  name            = var.root_domain
  type            = "MX"
  value           = "alt3.aspmx.l.google.com"
  priority        = 10
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "mx4" {
  zone_id         = var.cloudflare_zone_id
  name            = var.root_domain
  type            = "MX"
  value           = "alt4.aspmx.l.google.com"
  priority        = 10
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "spf" {
  zone_id         = var.cloudflare_zone_id
  name            = var.root_domain
  type            = "TXT"
  value           = "v=spf1 include:_spf.google.com -all"
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "_dmarc" {
  zone_id         = var.cloudflare_zone_id
  name            = "_dmarc"
  type            = "TXT"
  value           = "v=DMARC1; p=reject; sp=reject; rua=mailto:admin@caseyspar.kz; ruf=mailto:dmarc@caseyspar.kz; fo=1; pct=5;"
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "keybase_site_verification" {
  zone_id         = var.cloudflare_zone_id
  name            = var.root_domain
  type            = "TXT"
  value           = "keybase-site-verification=fz6Bnb_tsLzfkjlhhFk1owgs0LQV2gLjDKyba_mGejY"
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "google_site_verification" {
  zone_id         = var.cloudflare_zone_id
  name            = var.root_domain
  type            = "TXT"
  value           = "google-site-verification=FNQjTPVGcuLx5QR1RdNpybd1BFkzCQ9o65rUDfH-88w"
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "google_domainkey" {
  zone_id         = var.cloudflare_zone_id
  name            = "google._domainkey"
  type            = "TXT"
  value           = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvQw8k6bXrWSLtmEGfQgx01HH9YeetKGTj4XE568UsZUl7koxUqyvNgQ7RvfKLps/ylR79nb/AIzPzlcOfApaKPie8dJAFqgdq5sDDEBAqSEtkKe7+FjbgwQFj1+5gMbLQ8lRVpwxXXREDbmM64RQkbFbus2Ou5c4+/+qrUeS8ekR3LMd/+7DGIMq1n52uDn0 S4a3v/PleEkDBrdKK89H97BtPv1s0WxFovAQlYYRjr1IxhhqURkZIqDmvPsjsWf0qY9g3Gnyp1tsFinuq1r5X28f7C86WcnfjwmfiQUh6adZ3mdPrVxwRwAkken5z/xMlRYmkfFqeakaLl+3iYIIxwIDAQAB"
  proxied         = false
  allow_overwrite = true
}

resource "cloudflare_record" "himself_pka" {
  zone_id         = var.cloudflare_zone_id
  name            = "himself._pka"
  type            = "TXT"
  value           = "v=pka1;fpr=A0A991E4CCE81E4AF0D5D07B3260255327CBCDA1;uri=https://keys.caseyspar.kz/public.asc"
  proxied         = false
  allow_overwrite = true
}
