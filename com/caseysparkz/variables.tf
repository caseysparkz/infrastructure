################################################################################
# Variables
#

# AWS ==========================================================================
variable "aws_region" {
  type        = string
  description = "AWS region to deploy to."
  sensitive   = false
  default     = "us-west-2"
}

# Cloudflare ===================================================================
variable "mx_servers" {
  type        = map(string)
  description = "MX servers for root domain. Syntax: {server: priority}."
  sensitive   = false
  default = {
    "mail.protonmail.ch"    = 10
    "mailsec.protonmail.ch" = 20
  }
}

variable "dkim_records" {
  type        = map(string)
  description = "DKIM (CNAME) for root domain. Syntax: {host: pointer}."
  sensitive   = false
  default = {
    "protonmail._domainkey"  = "protonmail.domainkey.d56wvdqzbgjl657p6p37duzymskqqisyreca5lrft72j35tshomoq.domains.proton.ch"
    "protonmail2._domainkey" = "protonmail2.domainkey.d56wvdqzbgjl657p6p37duzymskqqisyreca5lrft72j35tshomoq.domains.proton.ch"
    "protonmail3._domainkey" = "protonmail3.domainkey.d56wvdqzbgjl657p6p37duzymskqqisyreca5lrft72j35tshomoq.domains.proton.ch"
  }
}

variable "spf_senders" {
  type        = list(string)
  description = "List of allowed SPF senders, like: [\"include:_spf.example.com\", \"ip4:127.0.0.1\"]."
  sensitive   = false
  default = [
    "include:_spf.protonmail.ch",
    "mx"
  ]
}

variable "txt_records" {
  type        = map(string)
  description = "List of TXT records for domain."
  sensitive   = false
  default = {
    "did=did:plc:eop37ikcn6s33dedyhvejqv5"                                  = "_atproto"
    "keybase-site-verification=tlIvxzz3OeL0u3nDrGVYrXRlNX0o62Xm0daTHOfLTQI" = "@"
  }
}

variable "pka_records" {
  type        = map(string)
  description = "Map of PKA handles and fingerprints for root domain."
  sensitive   = false
  default     = { himself = "133898B4C51BC39479E97F1B2027DEDFECE6A3D5" }
}

# Misc. ========================================================================
variable "root_domain" {
  type        = string
  description = "Root domain of Terraform infrastructure."
  sensitive   = false
  default     = "caseysparkz.com"
}
