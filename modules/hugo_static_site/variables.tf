###############################################################################
# Variables.
#

# Cloudflare ==================================================================
variable "turnstile_site_key" {
  type        = string
  description = "Site key for the Cloudflare Turnstile widget."
  sensitive   = true

  validation {
    condition     = can(regex("^0x[a-zA-Z0-9]{22}", var.turnstile_site_key))
    error_message = "Invalid Turnstile site key."
  }
}

variable "turnstile_secret_key" {
  type        = string
  description = "Secret key for the Cloudflare Turnstile widget."
  sensitive   = true

  validation {
    condition     = can(regex("^0x[a-zA-Z0-9]{33}", var.turnstile_secret_key))
    error_message = "Invalid Turnstile secret key."
  }
}

# Lambda ======================================================================
variable "artifact_bucket_id" {
  type        = string
  description = "ID of the S3 bucket in which lambda functions are kept."
  sensitive   = false
}

# Misc. =======================================================================
variable "root_domain" {
  type        = string
  description = "Root domain of Terraform infrastructure."
  sensitive   = false
}

variable "subdomain" {
  type        = string
  description = "Subdomain of Terraform infrastructure."
  sensitive   = false
}

variable "site_title" {
  type        = string
  description = "Title of the website."
  sensitive   = false
}

variable "hugo_dir" {
  type        = string
  description = "Absolute path of the Hugo directory."
  sensitive   = false

  validation {
    condition     = fileexists("${var.hugo_dir}/config.yml")
    error_message = "${var.hugo_dir}/config.yml does not exist."
  }
}
