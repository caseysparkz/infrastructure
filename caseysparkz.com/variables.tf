################################################################################
# Variables
#

# AWS ==========================================================================
variable "aws_region" {
  type        = string
  description = "AWS region to deploy to."
  sensitive   = false
  default     = "us-west-2"

  validation {
    condition     = contains(["us-east-1", "us-west-2"], var.aws_region)
    error_message = "AWS region not in ['us-east-1', 'us-west-2']."
  }
}

# Cloudflare ===================================================================
variable "mx_servers" {
  type        = map(string)
  description = "MX servers for root domain. Syntax: {server: priority}."
  sensitive   = false
  default     = {}
}

variable "dkim_records" {
  type        = map(string)
  description = "DKIM (CNAME) for root domain. Syntax: {host: pointer}."
  sensitive   = false
  default     = {}
}

variable "spf_senders" {
  type        = list(string)
  description = "List of allowed SPF senders, like: [\"include:_spf.example.com\", \"ip4:127.0.0.1\"]."
  sensitive   = false
  default     = []
}

variable "txt_records" {
  type        = map(string)
  description = "List of TXT records for domain."
  sensitive   = false
  default     = {}
}

variable "pka_records" {
  type        = map(string)
  description = "Map of PKA handles and fingerprints for root domain."
  sensitive   = false
  default     = {}
}

# Misc. ========================================================================
variable "root_domain" {
  type        = string
  description = "Root domain of Terraform infrastructure."
  sensitive   = false
  default     = "caseysparkz.com"
}
