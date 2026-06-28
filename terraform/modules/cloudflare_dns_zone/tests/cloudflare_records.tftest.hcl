###############################################################################
# Cloudflare Tests
#

# Variables ===================================================================
variables {
  zone_id         = "5ddfe1f2-7055-4ea9-a2c0-eab48ce120db"
  default_comment = "TEST_COMMENT"
  dns_records = [
    {
      name    = "test1"
      value   = "test.com"
      type    = "CNAME"
      ttl     = 2
      proxied = true
    },
    {
      name  = "www"
      value = "test"
      type  = "TXT"
    }
  ]
}


# Tests =======================================================================
run "cloudflare_record" {
  assert { #                                                                    Zone ID.
    condition = alltrue([
      for record in cloudflare_record.record :
      record.zone_id == "5ddfe1f2-7055-4ea9-a2c0-eab48ce120db"
    ])
    error_message = "Cloudflare record zone ID mismatch."
  }
  assert { #                                                                    Name.
    condition     = cloudflare_record.record[0].name == "test1"
    error_message = "Cloudflare record name mismatch."
  }
  assert { #                                                                    Value.
    condition     = cloudflare_record.record[0].value == "test.com"
    error_message = "Cloudflare record value mismatch."
  }
  assert { #                                                                    Type.
    condition     = cloudflare_record.record[0].type == "CNAME"
    error_message = "Cloudflare record type mismatch."
  }
  assert { #                                                                    TTL 1/2.
    condition     = cloudflare_record.record[0].ttl == 2
    error_message = "Cloudflare record TTL mismatch."
  }
  assert { #                                                                    TTL 2/2.
    condition     = cloudflare_record.record[1].ttl == 1
    error_message = "Cloudflare record default TTL mismatch."
  }
  assert { #                                                                    Proxied 1/2.
    condition     = cloudflare_record.record[0].proxied == true
    error_message = "Cloudflare record proxy mismatch."
  }
  assert { #                                                                    Proxied 2/2.
    condition     = cloudflare_record.record[1].proxied == false
    error_message = "Cloudflare record default proxy mismatch."
  }
  assert { #                                                                    Comment.
    condition     = alltrue([for record in cloudflare_record.record : record.comment == "TEST_COMMENT"])
    error_message = "Cloudflare record comment mismatch."
  }
}
