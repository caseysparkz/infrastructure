###############################################################################
# Variables
#

variable "routeros_hostname" {
  description = "Hostname of the RouterOS device."
  type        = string
  sensitive   = false
  default     = "ap01.home.caseyspar.kz"
}

variable "routeros_username" {
  description = "Username of the RouterOS user."
  type        = string
  sensitive   = false
  default     = "admin"
}

variable "routeros_password" {
  description = "Password of the RouterOS device."
  type        = string
  sensitive   = true
}

variable "routeros_ca_certificate" {
  description = "Path to the RouterOS CA certificate."
  type        = string
  sensitive   = false
}

variable "routeros_certificate" {
  description = "Path to the RouterOS TLS certificate."
  type        = string
  sensitive   = false
}

variable "routeros_certificate_key" {
  description = "Path to the RouterOS TLS certificate private key."
  type        = string
  sensitive   = false
}

variable "routeros_vlan_mgmt" {
  description = "Management VLAN ID."
  type        = number
  sensitive   = false
  default     = 4000
}

variable "routeros_ntp_servers" {
  description = "List of NTP server IPs."
  type        = list(string)
  sensitive   = false
  default     = ["172.16.1.1"]
}

variable "routeros_dhcp" {
  description = "DHCP server configuration."
  type        = map(string)
  sensitive   = false
  default = {
    address    = "192.168.88.1"
    network    = "192.168.88.0"
    prefix_len = "24"
    range      = "192.168.88.1-192.168.88.254"
  }
}

variable "routeros_wifipasswd_default" {
  description = "Password for the default SSID."
  type        = string
  sensitive   = true
}

variable "routeros_wifipasswd_iot" {
  description = "Password for the IoT SSID."
  type        = string
  sensitive   = true
}

variable "routeros_wifipasswd_trusted" {
  description = "Password for the trusted SSID."
  type        = string
  sensitive   = true
}
