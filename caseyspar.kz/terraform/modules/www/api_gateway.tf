###############################################################################
# AWS API Gateway
#

## Resources ==================================================================
resource "aws_api_gateway_resource" "contact_form" {
  rest_api_id = var.api_gateway_id
  parent_id   = var.api_gateway_root_resource_id
  path_part   = "contact"
}

resource "aws_api_gateway_method" "contact_form" {
  depends_on       = [aws_api_gateway_integration.contact_form]
  rest_api_id      = var.api_gateway_id
  resource_id      = aws_api_gateway_resource.contact_form.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "contact_form" {
  rest_api_id             = var.api_gateway_id
  resource_id             = aws_api_gateway_resource.contact_form.id
  http_method             = "POST"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.contact_form.invoke_arn
}

resource "aws_api_gateway_deployment" "contact_form" {
  depends_on  = [aws_api_gateway_method.contact_form]
  rest_api_id = var.api_gateway_id
}

resource "aws_api_gateway_stage" "contact_form" {
  deployment_id = aws_api_gateway_deployment.contact_form.id
  rest_api_id   = var.api_gateway_id
  stage_name    = "contact"
}
