###############################################################################
# Variables.
#

# Cloudflare ==================================================================
variable "turnstile_site_key" {
  description = "Site key for the Cloudflare Turnstile widget."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^0x[a-zA-Z0-9]{22}", var.turnstile_site_key))
    error_message = "Invalid Turnstile site key."
  }
}

variable "turnstile_secret_key" {
  description = "Secret key for the Cloudflare Turnstile widget."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^0x[a-zA-Z0-9]{33}", var.turnstile_secret_key))
    error_message = "Invalid Turnstile secret key."
  }
}

# Lambda ======================================================================
variable "artifact_bucket_id" {
  description = "ID of the S3 bucket in which lambda functions are kept."
  type        = string
  sensitive   = false
}

# Misc. =======================================================================
variable "root_domain" {
  description = "Root domain of Terraform infrastructure."
  type        = string
  sensitive   = false
}

variable "subdomain" {
  description = "Subdomain of Terraform infrastructure."
  type        = string
  sensitive   = false
}

variable "site_title" {
  description = "Title of the website."
  type        = string
  sensitive   = false
}

variable "hugo_dir" {
  description = "Absolute path of the Hugo directory."
  type        = string
  sensitive   = false

  validation {
    condition     = fileexists("${var.hugo_dir}/config.yml")
    error_message = "${var.hugo_dir}/config.yml does not exist."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  sensitive   = false
  default     = { terraform = true }
}
