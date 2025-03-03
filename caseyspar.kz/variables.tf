###############################################################################
# Variables
#

## AWS ========================================================================
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

variable "ecr_repository_names" {
  type        = list(string)
  description = "List of ECR repository names to create."
  sensitive   = false
  default     = []

  validation {
    condition     = alltrue([for v in var.ecr_repository_names : can(regex("^[a-zA-Z0-9_./]*$", v))])
    error_message = "ECR repository name contains invalid characters [a-zA-Z0-9-_./]."
  }
}

## Cloudflare =================================================================
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

variable "forward_zones" {
  type        = list(string)
  description = "Forward zones for the root domain."
  sensitive   = false
  default     = []
}

## GitHub =====================================================================
variable "github_owner" {
  description = "GitHub account to manage."
  type        = string
  sensitive   = true
}

variable "github_repositories" {
  description = "Map of GitHub repositories that should exist in the organization."
  type        = map(map(string))
  sensitive   = false
}

## Misc. ======================================================================
variable "root_domain" {
  type        = string
  description = "Root domain of Terraform infrastructure."
  sensitive   = false
}

variable "ssh_pubkey_path" {
  type        = string
  description = "Path of the administrator SSH public key."
  sensitive   = false
  default     = "~/.ssh/keys/id_rsa.pub"

  validation {
    condition     = fileexists(var.ssh_pubkey_path)
    error_message = "SSH pubkey file does not exist: ${var.ssh_pubkey_path}."
  }
}
