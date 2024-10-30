###############################################################################
# AWS Cloudwatch
#

# Tests =======================================================================
run "aws_cloudwatch_log_group_lambda_contact_form" {
  assert {
    condition     = startswith(aws_cloudwatch_log_group.lambda_contact_form.name, "/aws/lambda/")
    error_message = "Invalid Cloudwatch log group name."
  }
}
