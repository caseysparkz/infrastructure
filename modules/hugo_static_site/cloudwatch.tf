###############################################################################
# AWS Cloudwatch
#

# Resources ===================================================================
resource "aws_cloudwatch_log_group" "lambda_contact_form" {
  name              = "/aws/lambda/${aws_lambda_function.contact_form.function_name}"
  retention_in_days = 14
}
