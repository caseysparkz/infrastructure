###############################################################################
# AWS API Gateway
#
locals {
  api_gateway_source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}::${var.api_gateway_id}/*/POST/${aws_api_gateway_resource.contact_form.id}"
}

# Resources ===================================================================
resource "aws_api_gateway_resource" "contact_form" {
  rest_api_id = var.api_gateway_id
  parent_id   = var.api_gateway_root_resource_id
  path_part   = "contact"
}

resource "aws_api_gateway_method" "contact_form" {
  rest_api_id   = var.api_gateway_id
  resource_id   = aws_api_gateway_resource.contact_form.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "contact_form" {
  rest_api_id             = var.api_gateway_id
  resource_id             = aws_api_gateway_method.contact_form.resource_id
  http_method             = aws_api_gateway_method.contact_form.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.contact_form.invoke_arn
}

resource "aws_api_gateway_deployment" "contact_form" {
  depends_on  = [aws_api_gateway_integration.contact_form]
  rest_api_id = var.api_gateway_id
  stage_name  = "contact"

  lifecycle {
    create_before_destroy = true
  }
}

# Outputs =====================================================================
output "aws_api_gateway_deployment_invoke_url" {
  description = "Invocation URL for the contact form API gateway deployment."
  value       = aws_api_gateway_deployment.contact_form.invoke_url
  sensitive   = false
}

output "aws_api_gateway_deployment_execution_arn" {
  description = "Execution ARN for the contact form API gateway deployment."
  value       = aws_api_gateway_deployment.contact_form.execution_arn
  sensitive   = false
}

output "aws_api_gateway_source_arn" {
  description = "ARN of the API gatway calling Lambda."
  value       = local.api_gateway_source_arn
  sensitive   = true
}
