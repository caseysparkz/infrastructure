###############################################################################
# Variables
#

## AWS ========================================================================
aws_region = "us-west-2"
ecr_repository_names = [
  "alpine_base",
  "python3_base",
]

## Cloudflare =================================================================
mx_servers = {
  "mail.protonmail.ch"    = 10
  "mailsec.protonmail.ch" = 20
}
dkim_records = {
  "protonmail._domainkey"  = "protonmail.domainkey.dlnhnljjvlx6bfjjsleqnfvszipy5ver4qdnit24cx6ufem2qzgfq.domains.proton.ch"
  "protonmail2._domainkey" = "protonmail2.domainkey.dlnhnljjvlx6bfjjsleqnfvszipy5ver4qdnit24cx6ufem2qzgfq.domains.proton.ch"
  "protonmail3._domainkey" = "protonmail3.domainkey.dlnhnljjvlx6bfjjsleqnfvszipy5ver4qdnit24cx6ufem2qzgfq.domains.proton.ch"
}
spf_senders = [
  "include:_spf.protonmail.ch",
  "mx",
]
txt_records = {
  "protonmail-verification=fe3be76ae32c8b2a12ec3e6348d6a598e4e4a4f3" = "@"
  "have-i-been-pwned-verification=dweb_4p3ixho2v4rzazpnhs3dahgz"     = "@"
}
pka_records = { himself = "133898B4C51BC39479E97F1B2027DEDFECE6A3D5" }

## GitHub =====================================================================
github_owner = "caseysparkz"
github_repositories = { #                                                       TODO
  infrastructure = {}
}

## Misc. ======================================================================
root_domain     = "caseyspar.kz"
ssh_pubkey_path = "~/.ssh/keys/hck.pub"
