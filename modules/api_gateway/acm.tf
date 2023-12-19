###############################################################################
# AWS ACM
#

# Resources ===================================================================
resource "aws_acm_certificate" "subdomain" {
  domain_name       = var.subdomain
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "subdomain" {
  certificate_arn         = aws_acm_certificate.subdomain.arn
  validation_record_fqdns = [for record in cloudflare_record.domain_validation : record.hostname]
}
