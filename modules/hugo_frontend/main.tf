###############################################################################
# Main
#
locals {
  common_tags = {
    service = var.subdomain
  }
  lambda_s3_object_key = "contact_form_handler.zip"
  email_headers = {
    default_recipient = "form@${var.root_domain}"
    default_sender    = "form@${var.subdomain}"
  }
}

# Data ========================================================================
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
