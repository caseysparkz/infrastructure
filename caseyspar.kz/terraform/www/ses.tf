###############################################################################
# AWS SES
#

## Locals =====================================================================
locals {}

## Resources ==================================================================
resource "aws_ses_domain_identity" "subdomain" {
  domain = var.subdomain
}

resource "aws_ses_domain_identity_verification" "subdomain" {
  domain     = aws_ses_domain_identity.subdomain.id
  depends_on = [cloudflare_record.ses_verification]
}

resource "aws_ses_domain_dkim" "subdomain" {
  domain = aws_ses_domain_identity.subdomain.id
}

resource "aws_ses_email_identity" "recipient" {
  email = local.email_headers["default_recipient"]
}

resource "aws_ses_email_identity" "sender" {
  email = local.email_headers["default_sender"]
}
