###############################################################################
# AWS API Gateway
#

# Resources ===================================================================
resource "aws_api_gateway_domain_name" "subdomain" {
  domain_name              = var.subdomain
  regional_certificate_arn = aws_acm_certificate_validation.subdomain.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_rest_api" "subdomain" {
  name = var.subdomain
}

resource "aws_api_gateway_rest_api_policy" "subdomain" {
  rest_api_id = aws_api_gateway_rest_api.subdomain.id
  policy      = data.aws_iam_policy_document.api_gateway.json
}
