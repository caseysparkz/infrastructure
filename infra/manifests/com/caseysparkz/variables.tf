################################################################################
# Variables
#

# AWS ==========================================================================
variable "aws_region" {
  description = "AWS region to deploy to."
  type        = string
  sensitive   = false
  default     = "us-west-2"
}

variable "aws_vpc_cidr" {
  description = "Subnet CIDR of the new VPC to create."
  default     = "10.250.0.0/16"
  type        = string

  validation {
    condition     = cidrsubnet(var.aws_vpc_cidr, 0, 0) == var.aws_vpc_cidr
    error_message = "Invalid CIDR."
  }
}

variable "enable_pfsense_iam_access_key" {
  description = "Whether or not to enable the IAM key used in the AWS VPC VPN Wizard."
  type        = bool
  sensitive   = false
  default     = false
}

# Cloudflare ===================================================================
variable "mx_servers" {
  description = "MX servers for root domain. Syntax: {server: priority}."
  type        = map(string)
  sensitive   = false
  default = {
    "mail.protonmail.ch"    = 10
    "mailsec.protonmail.ch" = 20
  }
}

variable "spf_senders" {
  description = "List of allowed SPF senders, like: [\"include:_spf.example.com\", \"ip4:127.0.0.1\"]."
  type        = list(string)
  sensitive   = false
  default = [
    "include:_spf.protonmail.ch",
    "mx"
  ]
}

variable "txt_records" {
  description = "List of TXT records for domain."
  type        = map(string)
  sensitive   = false
  default = {
    "did=did:plc:eop37ikcn6s33dedyhvejqv5" = "_atproto"
  }
}

variable "pka_records" {
  description = "Map of PKA handles and fingerprints for root domain."
  type        = map(string)
  sensitive   = false
  default     = { himself = "133898B4C51BC39479E97F1B2027DEDFECE6A3D5" }
}

# Misc. ========================================================================
variable "root_domain" {
  description = "Root domain of Terraform infrastructure."
  type        = string
  sensitive   = false
  default     = "caseysparkz.com"
}
