###############################################################################
# Main
#

## Locals =====================================================================
locals {
  common_tags = merge(
    var.common_tags,
    {
      terraform = true
      domain    = var.root_domain
      service   = var.subdomain
    }
  )
  lambda_function_name  = aws_lambda_function.contact_form.function_name
  apigateway_url        = aws_apigatewayv2_api.lambda_contact_form.api_endpoint
  contact_form_endpoint = local.apigateway_url
  email_headers = {
    default_recipient = "form@${var.root_domain}"
    default_sender    = "form@${var.subdomain}"
  }
}
