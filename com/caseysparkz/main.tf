################################################################################
# Main
#

locals {
  common_tags = {
    Terraform = true
    Domain    = var.root_domain
  }
  dmarc_list = [ # Parsed to string
    { key = "p", value = "reject" },
    { key = "sp", value = "reject" },
    { key = "adkim", value = "s" },
    { key = "aspf", value = "s" },
    { key = "fo", value = 1 },
    { key = "pct", value = 5 },
    { key = "rua", value = "mailto:dmarc_rua@${var.root_domain}" },
    { key = "ruf", value = "mailto:dmarc_ruf@${var.root_domain}" },
  ]
  dmarc_policy = join(";", [for item in local.dmarc_list : "${item.key}=${item.value}"]) # Parse local.dmarc_list
}

# Modules ======================================================================
# Proton: @ --------------------------------------------------------------------
module "proton" {
  source             = "../../modules/proton_domain"
  cloudflare_zone_id = local.cloudflare_zone_id
  cloudflare_comment = local.cloudflare_comment
  domain             = var.root_domain
  txt_verification   = "protonmail-verification=af8861ffc1961e58bfc47af155f91c468923c49d"
  spf_record         = "v=spf1 include:_spf.protonmail.ch -all"
  dmarc_policy       = local.dmarc_policy
  dkim_record = {
    "protonmail._domainkey"  = "protonmail.domainkey.d56wvdqzbgjl657p6p37duzymskqqisyreca5lrft72j35tshomoq.domains.proton.ch."
    "protonmail2._domainkey" = "protonmail2.domainkey.d56wvdqzbgjl657p6p37duzymskqqisyreca5lrft72j35tshomoq.domains.proton.ch."
    "protonmail3._domainkey" = "protonmail3.domainkey.d56wvdqzbgjl657p6p37duzymskqqisyreca5lrft72j35tshomoq.domains.proton.ch."
  }
}

# Proton: home. ----------------------------------------------------------------
module "proton_home" {
  source             = "../../modules/proton_domain"
  cloudflare_zone_id = local.cloudflare_zone_id
  cloudflare_comment = local.cloudflare_comment
  domain             = "home.${var.root_domain}"
  txt_verification   = "protonmail-verification=9b021e210af76144b6841abcc22762b764d6636b"
  mx_record          = {}
  spf_record         = "v=spf1 include:_spf.protonmail.ch -all"
  dmarc_policy       = local.dmarc_policy
  dkim_record = {
    "protonmail._domainkey"  = "protonmail.domainkey.d4gc64isfcsi5uij7rmm2nggww7zvww7zvmtyw5guqxefeghia2wq.domains.proton.ch."
    "protonmail2._domainkey" = "protonmail2.domainkey.d4gc64isfcsi5uij7rmm2nggww7zvww7zvmtyw5guqxefeghia2wq.domains.proton.ch."
    "protonmail3._domainkey" = "protonmail3.domainkey.d4gc64isfcsi5uij7rmm2nggww7zvww7zvmtyw5guqxefeghia2wq.domains.proton.ch."
  }
}
