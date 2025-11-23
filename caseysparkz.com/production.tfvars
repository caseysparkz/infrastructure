################################################################################
# Variables
#

# Cloudflare ===================================================================
mx_servers = {
  "mail.protonmail.ch"    = 10
  "mailsec.protonmail.ch" = 20
}
dkim_records = {
  "protonmail._domainkey"  = "protonmail.domainkey.d56wvdqzbgjl657p6p37duzymskqqisyreca5lrft72j35tshomoq.domains.proton.ch"
  "protonmail2._domainkey" = "protonmail2.domainkey.d56wvdqzbgjl657p6p37duzymskqqisyreca5lrft72j35tshomoq.domains.proton.ch"
  "protonmail3._domainkey" = "protonmail3.domainkey.d56wvdqzbgjl657p6p37duzymskqqisyreca5lrft72j35tshomoq.domains.proton.ch"
}
spf_senders = ["include:_spf.protonmail.ch", "mx"]
txt_records = {
  "did=did:plc:eop37ikcn6s33dedyhvejqv5"                                  = "_atproto"
  "keybase-site-verification=tlIvxzz3OeL0u3nDrGVYrXRlNX0o62Xm0daTHOfLTQI" = "@"
}
pka_records = { himself = "133898B4C51BC39479E97F1B2027DEDFECE6A3D5" }
