###############################################################################
# Cloudflare
#

# Variables ===================================================================
variables {
  turnstile_site_key   = "0x0000000000000000000000"
  turnstile_secret_key = "0x111111111111111111111111111111111"
  artifact_bucket_id   = ""
  root_domain          = "test.com"
  subdomain            = "www.test.com"
  site_title           = "Test Title"
  hugo_dir             = "./hugo"
}

run "cloudflare_record_root_cname" {
  assert { #                                                                    Name.
    condition     = cloudflare_record.root_cname.name == "test.com"
    error_message = "Cloudflare record name mismatch."
  }
  assert { #                                                                    Type.
    condition     = cloudflare_record.root_cname.type == "CNAME"
    error_message = "Cloudflare record type mismatch."
  }
  assert { #                                                                    TTL.
    condition     = cloudflare_record.root_cname.ttl == 1
    error_message = "Cloudflare record TTL mismatch."
  }
  assert { #                                                                    Proxy.
    condition     = cloudflare_record.root_cname.proxied == true
    error_message = "Cloudflare record proxy mismatch."
  }
}

run "cloudflare_record_subdomain_cname" {
  assert { #                                                                    Name.
    condition     = cloudflare_record.subdomain_cname.name == "www.test.com"
    error_message = "Cloudflare record name mismatch."
  }
  assert { #                                                                    Type.
    condition     = cloudflare_record.subdomain_cname.type == "CNAME"
    error_message = "Cloudflare record type mismatch."
  }
  assert { #                                                                    TTL.
    condition     = cloudflare_record.subdomain_cname.ttl == 1
    error_message = "Cloudflare record TTL mismatch."
  }
  assert { #                                                                    Proxy.
    condition     = cloudflare_record.subdomain_cname.proxied == true
    error_message = "Cloudflare record proxy mismatch."
  }
}

run "cloudflare_record_ses_verification" {
  assert { #                                                                    Name.
    condition     = startswith(cloudflare_record.ses_verification.name, "_amazonses.")
    error_message = "Invalid SES verification."
  }
  assert { #                                                                    Type.
    condition     = cloudflare_record.ses_verification.type == "TXT"
    error_message = "Invalid SES verification record type."
  }
  assert { #                                                                    TTL.
    condition     = cloudflare_record.ses_verification.ttl == 1
    error_message = "SES verification record TTL mismatch."
  }
  assert { #                                                                    TTL.
    condition     = cloudflare_record.ses_verification.proxied == false
    error_message = "SES verification record proxied."
  }
}

run "cloudflare_record_subdomain_mx" {
  assert { #                                                                    Name.
    condition     = cloudflare_record.subdomain_mx.name == "www.test.com"
    error_message = "MX record name mismatch."
  }
  assert { #                                                                    Value.
    condition     = startswith(cloudflare_record.subdomain_mx.value, "feedback-smtp.")
    error_message = "Invalid MX record value."
  }
  assert { #                                                                    Type.
    condition     = cloudflare_record.subdomain_mx.type == "MX"
    error_message = "Invalid MX record type."
  }
  assert { #                                                                    TTL.
    condition     = cloudflare_record.subdomain_mx.ttl == 1
    error_message = "MX record TTL mismatch."
  }
}

run "cloudflare_record_subdomain_spf" {
  assert { #                                                                    Name.
    condition     = cloudflare_record.subdomain_spf.name == "www.test.com"
    error_message = "SPF record name mismatch."
  }
  assert { #                                                                    Value.
    condition     = cloudflare_record.subdomain_spf.value == "v=spf1 include:amazonses.com -all"
    error_message = "SPF record value mismatch."
  }
  assert { #                                                                    Type.
    condition     = cloudflare_record.subdomain_spf.type == "TXT"
    error_message = "SPF record type mismatch."
  }
  assert { #                                                                    Proxy.
    condition     = cloudflare_record.subdomain_spf.proxied == false
    error_message = "SPF record proxy mismatch."
  }
}

run "cloudflare_record_dkim" {
  assert { #                                                                    Count.
    condition     = length(cloudflare_record.dkim) == 3
    error_message = "Wrong number of DKIM records."
  }
  assert { #                                                                    TTL.
    condition     = alltrue([for record in cloudflare_record.dkim : record.ttl == 1])
    error_message = "DKIM record TTL mismatch."
  }
  assert { #                                                                    Type.
    condition     = alltrue([for record in cloudflare_record.dkim : record.type == "CNAME"])
    error_message = "DKIM record type mismatch."
  }
  assert { #                                                                    Proxy.
    condition     = alltrue([for record in cloudflare_record.dkim : record.proxied == false])
    error_message = "DKIM record proxy mismatch."
  }
  assert { #                                                                    Name.
    condition     = alltrue([for record in cloudflare_record.dkim : endswith(record.name, "._domainkey.test.com")])
    error_message = "DKIM record name mismatch."
  }
  assert { #                                                                    Value.
    condition     = alltrue([for record in cloudflare_record.dkim : endswith(record.value, ".dkim.amazonses.com")])
    error_message = "DKIM record type mismatch."
  }
}
