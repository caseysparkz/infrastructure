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
}

variable "dkim_records" {
  description = "DKIM (CNAME) for root domain. Syntax: {host: pointer}."
  type        = map(string)
  sensitive   = false
}

variable "spf_senders" {
  description = "List of allowed SPF senders, like: [\"include:_spf.example.com\", \"ip4:127.0.0.1\"]."
  type        = list(string)
  sensitive   = false
}

variable "txt_records" {
  description = "List of TXT records for domain."
  type        = map(string)
  sensitive   = false
}

variable "forward_zones" {
  description = "Forward zones for the root domain."
  type        = list(string)
  sensitive   = false
  default     = []
}

## Misc. ======================================================================
variable "root_domain" {
  description = "Root domain of Terraform infrastructure."
  default     = "centripedalporch.com"
  type        = string
  sensitive   = false
}
