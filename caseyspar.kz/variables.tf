###############################################################################
# Variables
#

## AWS ========================================================================
variable "aws_region" {
  description = "AWS region to deploy to."
  type        = string
  sensitive   = false
  default     = "us-west-2"

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

variable "ecr_repository_names" {
  description = "List of ECR repository names to create."
  type        = list(string)
  sensitive   = false
  default = [
    "alpine_base",
    "python3_base"
  ]

  validation {
    condition = alltrue([
      for v in var.ecr_repository_names : can(regex("^[a-zA-Z0-9_./]*$", v))
    ])
    error_message = "ECR repository name contains invalid characters [a-zA-Z0-9-_./]."
  }
}

## Cloudflare =================================================================
variable "cloudflare_api_token" {
  description = "API token for Cloudflare authentication."
  type        = string
  sensitive   = true
}

variable "mx_servers" {
  description = "MX servers for root domain. Syntax: {server: priority}."
  type        = map(string)
  sensitive   = false
  default = {
    "mail.protonmail.ch"    = 10
    "mailsec.protonmail.ch" = 20
  }
}

variable "dkim_records" {
  description = "DKIM (CNAME) for root domain. Syntax: {host: pointer}."
  type        = map(string)
  sensitive   = false
  default = {
    "protonmail._domainkey"  = "protonmail.domainkey.dlnhnljjvlx6bfjjsleqnfvszipy5ver4qdnit24cx6ufem2qzgfq.domains.proton.ch"
    "protonmail2._domainkey" = "protonmail2.domainkey.dlnhnljjvlx6bfjjsleqnfvszipy5ver4qdnit24cx6ufem2qzgfq.domains.proton.ch"
    "protonmail3._domainkey" = "protonmail3.domainkey.dlnhnljjvlx6bfjjsleqnfvszipy5ver4qdnit24cx6ufem2qzgfq.domains.proton.ch"
  }
}

variable "spf_senders" {
  description = "List of allowed SPF senders, like: [\"include:_spf.example.com\", \"ip4:127.0.0.1\"]."
  type        = list(string)
  default = [
    "include:_spf.protonmail.ch",
    "mx"
  ]
  sensitive = false
}

variable "txt_verification_records" {
  description = "List of verification TXT records for root domain."
  type        = map(string)
  sensitive   = false
  default = {
    "@"        = "keybase-site-verification=8MXkrublC6Bg6NPBvHAwmK12v1FledQETZS1ux_oi0A"
    "@"        = "protonmail-verification=fe3be76ae32c8b2a12ec3e6348d6a598e4e4a4f3"
    "_atproto" = "did=did:plc:eop37ikcn6s33dedyhvejqv5"
  }
}

variable "pka_records" {
  description = "Map of PKA handles and fingerprints for root domain."
  type        = map(string)
  default = {
    himself = "133898B4C51BC39479E97F1B2027DEDFECE6A3D5"
  }
  sensitive = false
}

variable "forward_zones" {
  description = "Forward zones for the root domain."
  type        = list(string)
  sensitive   = false
  default     = ["cspar.kz"]
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
