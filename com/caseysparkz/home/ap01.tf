################################################################################
# sw01.home.caseysparkz.com
#

# Resources ====================================================================
# /interface -------------------------------------------------------------------
resource "routeros_interface_bridge" "ap01" {
  provider = routeros.ap01

  disabled = false
  comment  = ""

  # General
  name                = "bridge01"
  mtu                 = "auto"
  arp                 = "enabled"
  arp_timeout         = "auto"
  auto_mac            = true
  ageing_time         = "5m"
  max_learned_entries = "auto"
  igmp_snooping       = true
  dhcp_snooping       = true
  add_dhcp_option82   = true
  fast_forward        = true

  # STP
  protocol_mode       = "rstp"
  priority            = "0x8000"
  port_cost_mode      = "long"
  max_message_age     = "20s"
  forward_delay       = "15s"
  transmit_hold_count = 6

  # VLAN
  vlan_filtering    = true
  ether_type        = "0x8100"
  pvid              = 1
  frame_types       = "admit-all"
  ingress_filtering = true
  mvrp              = false

  # IGMP Snooping
  igmp_version            = 2
  mld_version             = 1
  multicast_router        = "temporary-query"
  multicast_querier       = false
  startup_query_count     = 2
  last_member_query_count = 2
  last_member_interval    = "1s"
  membership_interval     = "4m20s"
  querier_interval        = "4m15s"
  query_interval          = "2m5s"
  query_response_interval = "10s"
  startup_query_interval  = "31s250ms"
}

resource "routeros_interface_vlan" "ap01_mgmt" {
  provider = routeros.ap01
  disabled = false
  comment  = ""

  # General
  name            = "vlan${var.management_vlan_id}_Mgmt"
  mtu             = "1500"
  arp             = "enabled"
  arp_timeout     = "auto"
  vlan_id         = var.management_vlan_id
  interface       = routeros_interface_bridge.ap01.name
  use_service_tag = false
  mvrp            = false

  # Loop Protect
  loop_protect               = "default"
  loop_protect_send_interval = "5s"
  loop_protect_disable_time  = "5m"
}

resource "routeros_interface_ethernet" "ap01" {
  for_each = {
    ether01 = {
      factory_name = "ether1"
      l2mtu        = 1568
      disabled     = false
    }
    ether02 = {
      factory_name = "ether2"
      l2mtu        = 1568
      disabled     = false
    }
  }
  provider = routeros.ap01
  disabled = lookup(each.value, "disabled", true)
  comment  = lookup(each.value, "comment", "")

  # General --------------------------------------------------------------------
  name         = each.key
  factory_name = lookup(each.value, "factory_name", each.key)
  mtu          = lookup(each.value, "mtu", 1500)
  l2mtu        = lookup(each.value, "l2mtu", 1592)
  arp          = lookup(each.value, "arp", "enabled")
  arp_timeout  = lookup(each.value, "arp_timeout", "auto")

  # Ethernet -------------------------------------------------------------------
  tx_flow_control  = lookup(each.value, "tx_flow_control", "off")
  rx_flow_control  = lookup(each.value, "rx_flow_control", "off")
  auto_negotiation = lookup(each.value, "auto_negotiation", true)
  advertise        = join(",", lookup(each.value, "advertise", local.default_advertise.eth))
  bandwidth        = lookup(each.value, "bandwidth", "unlimited/unlimited")

  # Loop Protect ---------------------------------------------------------------
  loop_protect               = lookup(each.value, "loop_protect", "default")
  loop_protect_send_interval = lookup(each.value, "loop_protect_send_interval", "5s")
  loop_protect_disable_time  = lookup(each.value, "loop_protect_disable_time", "5m")
}

# /interface/bridge ------------------------------------------------------------
/* TODO
resource "routeros_interface_bridge_port" "ap01" {}
*/

# /ip --------------------------------------------------------------------------
resource "routeros_ip_service" "ap01_disabled" {
  provider = routeros.ap01
  for_each = local.disabled_services
  numbers  = each.key
  port     = each.value
  vrf      = "main"
  disabled = true
}

resource "routeros_ip_service" "ap01_enabled" {
  provider = routeros.ap01
  for_each = local.enabled_services
  numbers  = each.key
  port     = each.value
  vrf      = "main"
  disabled = false
}

resource "routeros_ip_service" "ap01_https" {
  provider    = routeros.ap01
  numbers     = "www-ssl"
  port        = var.https_port
  certificate = "ap01.home.caseysparkz.com.p12_0"
  tls_version = "only-1.2"
  vrf         = "main"
  disabled    = false
}

# /system ----------------------------------------------------------------------
resource "routeros_system_identity" "ap01" {
  provider = routeros.ap01
  name     = "ap01"
}

resource "routeros_system_ntp_client" "ap01" {
  provider = routeros.ap01
  enabled  = true
  mode     = "unicast"
  servers  = var.ntp_servers
  vrf      = "main"
}

resource "routeros_system_clock" "ap01" {
  provider             = routeros.ap01
  time_zone_autodetect = true
}
