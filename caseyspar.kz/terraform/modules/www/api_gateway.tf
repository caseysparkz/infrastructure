###############################################################################
# AWS API Gateway
#

## Locals =====================================================================
locals {
  lambda_url = aws_apigatewayv2_stage.lambda_contact_form.invoke_url
}

## Resources ==================================================================
resource "aws_apigatewayv2_api" "lambda_contact_form" {
  name          = "lambda_contact_form_gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda_contact_form" {
  api_id      = aws_apigatewayv2_api.lambda_contact_form.id
  name        = "lambda_contact_form_gateway_stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.lambda_contact_form.arn
    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }
}

resource "aws_apigatewayv2_integration" "lambda_contact_form" {
  api_id             = aws_apigatewayv2_api.lambda_contact_form.id
  integration_uri    = aws_lambda_function.contact_form.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "lambda_contact_form" {
  api_id    = aws_apigatewayv2_api.lambda_contact_form.id
  route_key = "POST /contact_form"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_contact_form.id}"
}
