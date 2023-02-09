variable "cloudflare_org_id" {
  description = "Cloudflare org ID."
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare org ID."
  type        = string
  sensitive   = true
}

variable "cloudflare_user_email" {
  description = "Cloudflare user account email."
  type        = string
  sensitive   = true
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token."
  type        = string
  sensitive   = true
}

variable "root_domain" {
  description = "Root domain."
  type        = string
  sensitive   = true
}
