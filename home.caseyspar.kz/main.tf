###############################################################################
# Main
#
# Author:       Casey Sparks
# Date:         July 16, 2024
# Description:  x

locals {}

# Data ========================================================================
data "routeros_interfaces" "interfaces" {}

data "routeros_x509" "certificate" { data = file(var.routeros_certificate) }

# Resources ===================================================================
# File ------------------------------------------------------------------------
resource "routeros_file" "certificate" {
  name     = "${var.routeros_hostname}.crt"
  contents = data.routeros_x509.certificate.pem
}

resource "routeros_file" "certificate_key" {
  name     = "${var.routeros_hostname}.key"
  contents = file(var.routeros_certificate_key)
}

resource "routeros_system_certificate" "certificate" {
  name        = "${var.routeros_hostname}.crt"
  common_name = data.routeros_x509.certificate.common_name

  import {
    cert_file_name = routeros_file.certificate.name
    key_file_name  = routeros_file.certificate_key.name
  }
}

# System ----------------------------------------------------------------------
resource "routeros_system_clock" "clock" {
  time_zone_name = "America/Los_Angeles"
}

resource "routeros_system_identity" "hostname" {
  name = "ap01"
}

resource "routeros_system_ntp_client" "ntp_client" {
  servers = var.routeros_ntp_servers
  mode    = "unicast"
  enabled = true
}

# Interfaces ------------------------------------------------------------------
resource "routeros_interface_ethernet" "ether01" {
  factory_name = "ether1"
  name         = "ether01"
}

resource "routeros_interface_ethernet" "ether02" {
  factory_name = "ether2"
  name         = "ether02"
}

resource "routeros_interface_bridge" "bridge01" {
  name           = "bridge01"
  vlan_filtering = true
}

resource "routeros_interface_vlan" "vlan4000" {
  name      = "vlan${var.routeros_vlan_mgmt}"
  interface = routeros_interface_bridge.bridge01.name
  vlan_id   = var.routeros_vlan_mgmt
}

resource "routeros_interface_bridge_port" "wlan01" {
  bridge    = routeros_interface_bridge.bridge01.name
  interface = "wlan1"
}

resource "routeros_interface_bridge_port" "wlan02" {
  bridge    = routeros_interface_bridge.bridge01.name
  interface = "wlan2"
}

resource "routeros_interface_bridge_port" "ether01" {
  bridge    = routeros_interface_bridge.bridge01.name
  interface = routeros_interface_ethernet.ether01.name
}

resource "routeros_interface_bridge_vlan" "vlan0001" {
  bridge   = routeros_interface_bridge.bridge01.name
  tagged   = [routeros_interface_ethernet.ether01.name]
  vlan_ids = [1]
}

resource "routeros_interface_bridge_vlan" "vlan0010" {
  bridge   = routeros_interface_bridge.bridge01.name
  tagged   = [routeros_interface_ethernet.ether01.name]
  vlan_ids = [10]
}

resource "routeros_interface_bridge_vlan" "vlan0100" {
  bridge   = routeros_interface_bridge.bridge01.name
  tagged   = [routeros_interface_ethernet.ether01.name]
  vlan_ids = [100]
}

resource "routeros_interface_bridge_vlan" "vlan4000" {
  bridge = routeros_interface_bridge.bridge01.name
  tagged = [
    routeros_interface_ethernet.ether01.name,
    routeros_interface_bridge.bridge01.name
  ]
  vlan_ids = [4000]
}

resource "routeros_interface_wireless_cap" "cap" {
  bridge      = routeros_interface_bridge.bridge01.name
  certificate = "request"
  discovery_interfaces = [
    routeros_interface_bridge.bridge01.name,
    routeros_interface_vlan.vlan4000.name
  ]
  interfaces = ["wlan1", "wlan2"]
  enabled    = true
}

# CAPsMAN ---------------------------------------------------------------------
resource "routeros_capsman_channel" "channel01" {
  name              = "channel01_Default"
  reselect_interval = "10m"
  skip_dfs_channels = true
}

resource "routeros_capsman_datapath" "datapath0001_default" {
  name             = "datapath0001_Default"
  vlan_id          = 1
  bridge           = routeros_interface_bridge.bridge01.name
  bridge_horizon   = 10
  local_forwarding = true
  vlan_mode        = "no-tag"
}

resource "routeros_capsman_datapath" "datapath0010_iot" {
  name             = "datapath0010_IoT"
  vlan_id          = 10
  bridge           = routeros_interface_bridge.bridge01.name
  bridge_horizon   = 10
  local_forwarding = true
  vlan_mode        = "use-tag"
}

resource "routeros_capsman_datapath" "datapath0100_trusted" {
  name             = "datapath0Trusted"
  vlan_id          = 100
  bridge           = routeros_interface_bridge.bridge01.name
  bridge_horizon   = 10
  local_forwarding = true
  vlan_mode        = "use-tag"
}

resource "routeros_capsman_security" "security01" {
  name                 = "security01_Default"
  authentication_types = ["wpa2-psk"]
  encryption           = ["aes-ccm"]
  group_encryption     = "aes-ccm"
  group_key_update     = "10m"
}

resource "routeros_capsman_configuration" "cfg0001_guest" {
  name         = "cfg0001_Guest"
  country      = "united states"
  mode         = "ap"
  hide_ssid    = false
  installation = "indoor"
  channel      = { config = routeros_capsman_channel.channel01.name }
  datapath     = { config = routeros_capsman_datapath.datapath0001_default.name }
  security = {
    config     = routeros_capsman_security.security01.name
    ssid       = "guest.caseyspar.kz"
    passphrase = var.routeros_wifipasswd_default
  }
}

resource "routeros_capsman_configuration" "cfg0010_iot" {
  name         = "cfg0010_IoT"
  country      = "united states"
  mode         = "ap"
  ssid         = "iot.caseyspar.kz"
  hide_ssid    = true
  installation = "indoor"
  channel      = { config = routeros_capsman_channel.channel01.name }
  datapath     = { config = routeros_capsman_datapath.datapath0010_iot.name }
  security = {
    config     = routeros_capsman_security.security01.name
    passphrase = var.routeros_wifipasswd_iot
  }
}

resource "routeros_capsman_configuration" "cfg0100_trusted" {
  name         = "cfg0100_Trusted"
  country      = "united states"
  mode         = "ap"
  ssid         = "home.caseyspar.kz"
  hide_ssid    = false
  installation = "indoor"
  channel      = { config = routeros_capsman_channel.channel01.name }
  datapath     = { config = routeros_capsman_datapath.datapath0100_trusted.name }
  security = {
    config     = routeros_capsman_security.security01.name
    passphrase = var.routeros_wifipasswd_trusted
  }
}

resource "routeros_capsman_manager" "capsman" {
  ca_certificate = "auto"
  certificate    = "auto"
  enabled        = true
}

resource "routeros_capsman_manager_interface" "bridge01" {
  interface = routeros_interface_bridge.bridge01.name
  forbid    = false
}

resource "routeros_capsman_manager_interface" "vlan4000" {
  interface = routeros_interface_vlan.vlan4000.name
  forbid    = false
}

resource "routeros_capsman_provisioning" "provisioning" {
  action               = "create-dynamic-enabled"
  master_configuration = routeros_capsman_configuration.cfg0001_guest.name
  name_format          = "identity"
  slave_configurations = join(
    ",",
    [
      routeros_capsman_configuration.cfg0010_iot.name,
      routeros_capsman_configuration.cfg0100_trusted.name
    ]
  )
}

# Wifi ------------------------------------------------------------------------
resource "routeros_wifi_interworking" "default01" {
  name              = "default01"
  ipv4_availability = "single-nated"
  network_type      = "private"
  venue             = "residential-private"
}

# IP --------------------------------------------------------------------------
resource "routeros_ip_pool" "dhcp_pool01" {
  name   = "dhcp_pool01"
  ranges = [var.routeros_dhcp.range]
}

resource "routeros_dhcp_server" "dhcp01" {
  name         = "dhcp01"
  address_pool = routeros_ip_pool.dhcp_pool01.name
  disabled     = false
  interface    = routeros_interface_ethernet.ether02.name
}

resource "routeros_ip_firewall_connection_tracking" "firewall" {
  enabled = "no"
}

resource "routeros_ip_neighbor_discovery_settings" "discovery" {
  discover_interface_list = "none"
  protocol                = []
}

resource "routeros_ip_address" "default01" {
  interface = routeros_interface_ethernet.ether02.name
  address   = "${var.routeros_dhcp.address}/${var.routeros_dhcp.prefix_len}"
  network   = var.routeros_dhcp.network
}

resource "routeros_ip_dhcp_client" "default01" {
  interface = routeros_interface_vlan.vlan4000.name
  disabled  = false
}

resource "routeros_ip_dhcp_server_network" "default01" {
  address  = "${var.routeros_dhcp.network}/${var.routeros_dhcp.prefix_len}"
  dns_none = true
  gateway  = var.routeros_dhcp.address
}

resource "routeros_ip_service" "telnet" {
  numbers  = "telnet"
  port     = "23"
  disabled = true
}

resource "routeros_ip_service" "ftp" {
  numbers  = "ftp"
  port     = 21
  disabled = true
}

resource "routeros_ip_service" "www" {
  numbers  = "www"
  port     = "80"
  disabled = true
}

resource "routeros_ip_service" "www-ssl" {
  numbers  = "www-ssl"
  port     = "80"
  disabled = false
}

resource "routeros_ip_service" "www_ssl" {
  numbers     = "www-ssl"
  port        = 8443
  certificate = routeros_system_certificate.certificate.name
  tls_version = "only-1.2"
  disabled    = false
}

resource "routeros_ip_service" "api" {
  numbers  = "api"
  port     = 8728
  disabled = true
}

resource "routeros_ip_service" "winbox" {
  numbers  = "winbox"
  port     = 8291
  disabled = true
}

resource "routeros_ip_service" "api_ssl" {
  numbers     = "api-ssl"
  port        = 8729
  certificate = routeros_system_certificate.certificate.name
  tls_version = "only-1.2"
  disabled    = false
}

resource "routeros_ip_ssh_server" "ssh" {
  strong_crypto               = true
  forwarding_enabled          = "no"
  always_allow_password_login = false
}

# Tools -----------------------------------------------------------------------
resource "routeros_tool_mac_server" "mac_server" {
  allowed_interface_list = "none"
}

resource "routeros_tool_mac_server_winbox" "mac_server_winbox" {
  allowed_interface_list = "none"
}
