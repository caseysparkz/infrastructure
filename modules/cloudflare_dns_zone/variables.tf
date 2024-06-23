###############################################################################
# Variables
#

variable "zone_id" {
  type        = string
  description = "Root domain of the deployed infrastructure."
  sensitive   = false
}

variable "dns_records" {
  type        = list(map(string))
  description = "Map of MX, TXT, and CNAME records to create."
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
  type        = string
  description = "Default comment to apply to all Cloudflare resources."
  sensitive   = false
  default     = "Terraform managed."
}
