###############################################################################
# AWS Cloudwatch
#

## Resources ==================================================================
resource "aws_cloudwatch_log_group" "lambda_contact_form" {
  name              = "/aws/lambda/${aws_lambda_function.contact_form.function_name}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "api_gateway_contact_form" {
  name              = "/aws/api_gw/${aws_apigatewayv2_api.lambda_contact_form.name}"
  retention_in_days = 30
}
