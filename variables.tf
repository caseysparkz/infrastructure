variable "root_domain" {
  description = "Root domain."
  type        = string
  sensitive   = true
}

variable "admin_ssh_pubkey" {
  description = "SSH pubkey"
  type        = string
  sensitive   = false
}

variable "admin_pgp_fingerprint" {
  description = "PGP fingerprint for administrator."
  type        = string
  sensitive   = false
}

variable "admin_pgp_key" {
  description = "PGP key for administrator."
  type        = string
  sensitive   = true
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  sensitive   = true
}

variable "aws_root_mfa_key_arns" {
  description = "AWS Root account MFA security keys"
  type        = list(string)
  sensitive   = true
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  sensitive   = false
  default     = "us-west-2"
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token."
  type        = string
  sensitive   = true
}

variable "cloudflare_org_id" {
  description = "Cloudflare org ID."
  type        = string
  sensitive   = true
}

variable "cloudflare_user_email" {
  description = "Cloudflare user account email."
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID."
  type        = string
  sensitive   = true
}
