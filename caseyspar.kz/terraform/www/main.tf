########################################################################################################################
# Locals
#

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
  apigateway_url        = aws_apigatewayv2_stage.lambda_contact_form.invoke_url
  contact_form_endpoint = "${local.apigateway_url}/${local.lambda_function_name}"
}
