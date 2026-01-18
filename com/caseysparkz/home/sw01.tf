################################################################################
# sw01.home.caseysparkz.com
#

locals {
  sw01_ports = {
    ether01 = {
      factory_name = "ether1"
      comment      = "01 - Bedroom"
      pvid         = 100
      disabled     = false
    }
    ether02 = {
      factory_name = "ether2"
      comment      = "02 - Bedroom"
      pvid         = 1
      disabled     = false
    }
    ether03 = {
      factory_name = "ether3"
      comment      = "03 - Living Room"
      pvid         = 10
      disabled     = false
    }
    ether04 = {
      factory_name      = "ether4"
      comment           = "04 - Living Room"
      pvid              = 1
      trusted           = true
      ingress_filtering = false # TODO
      frame_types       = "admit-all"
      disabled          = false
    }
    ether05 = {
      factory_name = "ether5"
      comment      = "05 - Office"
      pvid         = 100
      disabled     = false
    }
    ether06 = {
      factory_name = "ether6"
      comment      = "06 - Office"
      pvid         = 100
      disabled     = false
    }
    ether07 = {
      factory_name = "ether7"
      comment      = "07 - Kitchen"
      pvid         = 1
      disabled     = false
    }
    ether08 = {
      factory_name = "ether8"
      comment      = "08 - Kitchen"
      disabled     = false
    }
    ether09 = {
      factory_name = "ether9"
      comment      = "hue.${var.lan_domain}"
      pvid         = 10
      disabled     = false
    }
    ether10 = {}
    ether11 = {}
    ether12 = {}
    ether13 = {}
    ether14 = {}
    ether15 = {}
    ether16 = {}
    ether17 = {}
    ether18 = {}
    ether19 = {}
    ether20 = {}
    ether21 = {}
    ether22 = {}
    ether23 = {}
    ether24 = {
      comment     = "fw01.${var.lan_domain}"
      frame_types = "admit-only-vlan-tagged"
      hw          = false
      trusted     = true
      pvid        = 1
      disabled    = false
    }
    sfp01 = {
      factory_name = "sfp-sfpplus1"
      advertise    = local.default_advertise.sfp
    }
    sfp02 = {
      factory_name = "sfp-sfpplus2"
      advertise    = local.default_advertise.sfp
    }
  }
}

# Resources ====================================================================
# /interface -------------------------------------------------------------------
resource "routeros_interface_bridge" "sw01" {
  provider = routeros.sw01

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
  port_cost_mode      = "short"
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
  multicast_querier       = true
  startup_query_count     = 2
  last_member_query_count = 2
  last_member_interval    = "1s"
  membership_interval     = "4m20s"
  querier_interval        = "4m15s"
  query_interval          = "2m5s"
  query_response_interval = "10s"
  startup_query_interval  = "31s250ms"
}

resource "routeros_interface_vlan" "sw01_mgmt" {
  provider = routeros.sw01
  disabled = false
  comment  = ""

  # General
  name            = "vlan${var.management_vlan_id}_Mgmt"
  mtu             = "1500"
  arp             = "enabled"
  arp_timeout     = "auto"
  vlan_id         = var.management_vlan_id
  interface       = routeros_interface_bridge.sw01.name
  use_service_tag = false
  mvrp            = false

  # Loop Protect
  loop_protect               = "default"
  loop_protect_send_interval = "5s"
  loop_protect_disable_time  = "5m"
}

resource "routeros_interface_ethernet" "sw01" {
  for_each = local.sw01_ports
  provider = routeros.sw01
  disabled = lookup(each.value, "disabled", true)
  comment  = lookup(each.value, "comment", "")

  # General --------------------------------------------------------------------
  name         = each.key
  factory_name = lookup(each.value, "factory_name", each.key)
  mtu          = lookup(each.value, "mtu", 1500)
  l2mtu        = lookup(each.value, "l2mtu", 1592)
  arp          = lookup(each.value, "arp", "enabled")
  arp_timeout  = lookup(each.value, "arp_timeout", "auto")

  # General --------------------------------------------------------------------
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
resource "routeros_interface_bridge_port" "sw01" {
  for_each                = local.sw01_ports
  provider                = routeros.sw01
  interface               = each.key
  comment                 = lookup(each.value, "comment", "")
  disabled                = lookup(each.value, "disabled", true)
  pvid                    = lookup(each.value, "pvid", 1)
  auto_isolate            = lookup(each.value, "auto_isolate", false)
  bpdu_guard              = lookup(each.value, "bpdu_guard", false)
  bridge                  = routeros_interface_bridge.sw01.name
  broadcast_flood         = lookup(each.value, "broadcast_flood", true)
  edge                    = lookup(each.value, "edge", "auto")
  fast_leave              = lookup(each.value, "fast_leave", false)
  frame_types             = lookup(each.value, "frame_types", "admit-only-untagged-and-priority-tagged")
  horizon                 = lookup(each.value, "horizon", "none")
  hw                      = lookup(each.value, "hw", true)
  ingress_filtering       = lookup(each.value, "ingress_filtering", true)
  internal_path_cost      = lookup(each.value, "internal_path_cost", 10)
  learn                   = lookup(each.value, "learn", "auto")
  multicast_router        = lookup(each.value, "multicast_router", "temporary-query")
  mvrp_applicant_state    = lookup(each.value, "mvrp_applicant_state", "normal-participant")
  mvrp_registrar_state    = lookup(each.value, "mvrp_registrar_state", "normal")
  path_cost               = lookup(each.value, "path_cost", "10")
  point_to_point          = lookup(each.value, "point_to_point", "auto")
  priority                = lookup(each.value, "priority", "0x80")
  restricted_role         = lookup(each.value, "restricted_role", false)
  restricted_tcn          = lookup(each.value, "restricted_tcn", false)
  tag_stacking            = lookup(each.value, "tag_stacking", false)
  trusted                 = lookup(each.value, "trusted", false)
  unknown_multicast_flood = lookup(each.value, "unknown_multicast_flood", true)
  unknown_unicast_flood   = lookup(each.value, "unknown_unicast_flood", true)
}

# /ip --------------------------------------------------------------------------
resource "routeros_ip_service" "sw01_disabled" {
  provider = routeros.sw01
  for_each = local.disabled_services
  numbers  = each.key
  port     = each.value
  vrf      = "main"
  disabled = true
}

resource "routeros_ip_service" "sw01_enabled" {
  provider = routeros.sw01
  for_each = local.enabled_services
  numbers  = each.key
  port     = each.value
  vrf      = "main"
  disabled = false
}

resource "routeros_ip_service" "sw01_https" {
  provider    = routeros.sw01
  numbers     = "www-ssl"
  port        = var.https_port
  certificate = "sw01.home.caseysparkz.com"
  tls_version = "only-1.2"
  vrf         = "main"
  disabled    = false
}

# /system ----------------------------------------------------------------------
resource "routeros_system_identity" "sw01" {
  provider = routeros.sw01
  name     = "sw01"
}

resource "routeros_system_ntp_client" "sw01" {
  provider = routeros.sw01
  enabled  = true
  mode     = "unicast"
  servers  = var.ntp_servers
  vrf      = "main"
}

resource "routeros_system_clock" "sw01" {
  provider             = routeros.sw01
  time_zone_autodetect = true
}
