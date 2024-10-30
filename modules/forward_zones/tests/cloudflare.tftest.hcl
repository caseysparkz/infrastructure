###############################################################################
# Main
#
variables {
  root_domain        = "test.com"
  forward_zones      = "example.com"
  cloudflare_comment = "TEST_COMMENT"
}

run "cloudflare_cname" {
  assert { #                                                                    Value.
    condition     = alltrue([for record in cloudflare_record.cname : record.value == "test.com"])
    error_message = "Cloudflare record value mismatch."
  }
  assert { #                                                                    Type.
    condition     = alltrue([for record in cloudflare_record.cname : record.type == "CNAME"])
    error_message = "Cloudflare record type mismatch."
  }
  assert { #                                                                    TTL.
    condition     = alltrue([for record in cloudflare_record.cname : record.ttl == 1])
    error_message = "Cloudflare record TTL mismatch."
  }
  assert { #                                                                    Proxy.
    condition     = alltrue([for record in cloudflare_record.cname : record.proxied == true])
    error_message = "Cloudflare record proxy mismatch."
  }
  assert { #                                                                    Comment.
    condition     = alltrue([for record in cloudflare_record.cname : record.comment == "TEST_COMMENT"])
    error_message = "Cloudflare record comment mismatch."
  }
}

run "cloudflare_cname_www" {
  assert { #                                                                    Value.
    condition     = alltrue([for record in cloudflare_record.cname : record.value == "test.com"])
    error_message = "Cloudflare record value mismatch."
  }
  assert { #                                                                    Name.
    condition     = alltrue([for record in cloudflare_record.cname_www : startswith(record.name, "www.")])
    error_message = "Cloudflare WWW record name mismatch."
  }
  assert { #                                                                    Type.
    condition     = alltrue([for record in cloudflare_record.cname_www : record.type == "CNAME"])
    error_message = "Cloudflare WWW record type mismatch."
  }
  assert { #                                                                    TTL.
    condition     = alltrue([for record in cloudflare_record.cname_www : record.ttl == 1])
    error_message = "Cloudflare WWW record TTL mismatch."
  }
  assert { #                                                                    Proxy.
    condition     = alltrue([for record in cloudflare_record.cname_www : record.proxied == true])
    error_message = "Cloudflare WWW record proxy mismatch."
  }
  assert { #                                                                    Comment.
    condition     = alltrue([for record in cloudflare_record.cname_www : record.comment == "TEST_COMMENT"])
    error_message = "Cloudflare WWW record comment mismatch."
  }
}
