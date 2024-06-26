###############################################################################
# Main
#
locals {}

# Resources ===================================================================
resource "cloudflare_record" "record" {
  count           = length(var.dns_records)
  zone_id         = var.zone_id
  name            = var.dns_records[count.index].name
  value           = var.dns_records[count.index].value
  type            = var.dns_records[count.index].type
  ttl             = lookup(var.dns_records[count.index], "ttl", 1)
  proxied         = lookup(var.dns_records[count.index], "proxied", false)
  allow_overwrite = lookup(var.dns_records[count.index], "allow_overwrite", false)
  comment         = var.default_comment
}

# Outputs =====================================================================
output "records" {
  description = "Zone data for the new Cloudflare zone."
  value       = cloudflare_record.record
  sensitive   = false
}
