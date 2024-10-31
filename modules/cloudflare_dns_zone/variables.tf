###############################################################################
# Variables
#

variable "zone_id" {
  description = "Root domain of the deployed infrastructure."
  type        = string
  sensitive   = false
}

variable "dns_records" {
  description = "Map of MX, TXT, and CNAME records to create."
  type        = list(map(string))
  sensitive   = false

  validation {
    condition     = alltrue([for record in var.dns_records : lookup(record, "name", "") != ""])
    error_message = "DNS record map object missing key 'name'."
  }
  validation {
    condition     = alltrue([for record in var.dns_records : lookup(record, "value", "") != ""])
    error_message = "DNS record map object missing key 'value'."
  }
  validation {
    condition     = alltrue([for record in var.dns_records : lookup(record, "type", "") != ""])
    error_message = "DNS record map object missing key 'type'."
  }
}

variable "default_comment" {
  description = "Default comment to apply to all Cloudflare resources."
  type        = string
  sensitive   = false
  default     = "Terraform managed."
}
