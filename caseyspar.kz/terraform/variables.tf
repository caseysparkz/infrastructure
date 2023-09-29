########################################################################################################################
# Variables
#

## AWS ========================================================================
variable "aws_region" {
  description = "AWS region to deploy to."
  default     = "us-west-2"
  type        = string
  sensitive   = false

  validation {
    condition     = contains(["us-east-1", "us-west-2"], var.aws_region)
    error_message = "AWS region not in ['us-east-1', 'us-west-2']."
  }
}

variable "aws_access_key" {
  description = "AWS access key for the deployment user."
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "Secret key corresponding to the AWS access key."
  type        = string
  sensitive   = true
}

## Cloudflare =================================================================
variable "cloudflare_api_token" {
  description = "API token for Cloudflare authentication."
  type        = string
  sensitive   = true
}

variable "forward_zones" {
  description = "Zones to forward to var.root_domain."
  default = [
    "cspar.kz",
  ]
  type      = list(string)
  sensitive = false
}

variable "mx_servers" {
  description = "MX servers for root domain. Syntax: {server: priority}."
  default = {
    "mail.protonmail.ch"    = 10
    "mailsec.protonmail.ch" = 20
  }
  type      = map(string)
  sensitive = false
}

variable "dkim_records" {
  description = "DKIM (CNAME) for root domain. Syntax: {host: pointer}."
  default = {
    "protonmail._domainkey"  = "protonmail.domainkey.dlnhnljjvlx6bfjjsleqnfvszipy5ver4qdnit24cx6ufem2qzgfq.domains.proton.ch"
    "protonmail2._domainkey" = "protonmail2.domainkey.dlnhnljjvlx6bfjjsleqnfvszipy5ver4qdnit24cx6ufem2qzgfq.domains.proton.ch"
    "protonmail3._domainkey" = "protonmail3.domainkey.dlnhnljjvlx6bfjjsleqnfvszipy5ver4qdnit24cx6ufem2qzgfq.domains.proton.ch"
  }
  type      = map(string)
  sensitive = false
}

variable "spf_senders" {
  description = "List of allowed SPF senders, like: [\"include:_spf.example.com\", \"ip4:127.0.0.1\"]."
  default = [
    "include:_spf.protonmail.ch",
    "mx"
  ]
  type      = list(string)
  sensitive = false
}

variable "verification_records" {
  description = "List of verification TXT records for root domain."
  default = [
    "keybase-site-verification=8MXkrublC6Bg6NPBvHAwmK12v1FledQETZS1ux_oi0A", #  Keybase.
    "protonmail-verification=fe3be76ae32c8b2a12ec3e6348d6a598e4e4a4f3"       #  Proton.
  ]
  type      = list(string)
  sensitive = false
}

variable "pka_records" {
  description = "Map of PKA handles and fingerprints for root domain."
  default = {
    himself = "133898B4C51BC39479E97F1B2027DEDFECE6A3D5"
  }
  type      = map(string)
  sensitive = false
}

## Misc. ======================================================================
variable "root_domain" {
  description = "Root domain of Terraform infrastructure."
  default     = "caseyspar.kz"
  type        = string
  sensitive   = false
}

variable "environment" {
  description = "The environment to deploy to."
  default     = "development"
  type        = string
  sensitive   = false

  validation {
    condition     = contains(["production", "staging", "development"], var.environment)
    error_message = "var.environment not in ['production', 'staging', 'development']."
  }
}

variable "environment_suffix_map" {
  description = "Suffix to auto-append based on chosen environment."
  default = {
    development = "-dev"
    staging     = "-stage"
    production  = ""
  }
  type      = map(string)
  sensitive = false
}

variable "ssh_pubkey_path" {
  description = "Path of the administrator SSH public key."
  default     = "~/.ssh/id_ed25519.pub"
  type        = string
  sensitive   = false
}