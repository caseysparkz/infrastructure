################################################################################
# Main
#
# Author:       Casey Sparks
# Date:         January 18, 2026
# Description:  Terraform provider for home LAN switching hardware.

locals {
  common_tags = { ManagedBy = "terraform" }
  default_advertise = {
    eth = [
      "10M-baseT-half",
      "10M-baseT-full",
      "100M-baseT-half",
      "100M-baseT-full",
      "1G-baseT-half",
      "1G-baseT-full",
    ]
    sfp = [
      "10M-baseT-half",
      "10M-baseT-full",
      "100M-baseT-half",
      "100M-baseT-full",
      "1G-baseT-half",
      "1G-baseT-full",
      "1G-baseX",
      "2.5G-baseT",
      "2.5G-baseX",
      "5G-baseT",
      "10G-baseT",
      "10G-baseSR-LR",
      "10G-baseCR",
    ]
  }
  enabled_services = { ssh = 22 }
  disabled_services = {
    api     = 8728
    api-ssl = 8729
    ftp     = 21
    telnet  = 23
    winbox  = 8291
    www     = 80
  }
}
