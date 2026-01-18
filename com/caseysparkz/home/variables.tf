################################################################################
# Variables
#

# AWS ==========================================================================
variable "aws_region" {
  type        = string
  description = "AWS region to deploy to."
  sensitive   = false
  default     = "us-west-2"
}

# LAN
variable "lan_domain" {
  type        = string
  description = "Domain of the local area network."
  sensitive   = false
  default     = "home.caseysparkz.com"
}

variable "management_vlan_id" {
  description = "Management VLAN ID."
  type        = number
  sensitive   = false
  default     = 4000
}

variable "ntp_servers" {
  description = "List of NTP server IP addresses."
  type        = list(string)
  default     = ["192.168.200.1"]
  sensitive   = false
}

variable "https_port" {
  description = "Port used by the HTTPS server."
  type        = number
  default     = 8443
  sensitive   = false
}
