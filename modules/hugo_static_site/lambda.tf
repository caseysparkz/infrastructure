###############################################################################
# AWS Lambda
#

# Data ========================================================================
data "archive_file" "lambda_contact_form" { #                                   TODO. Will redeploy every time.
  type        = "zip"
  source_file = "${path.module}/lambda_contact_form.py"
  output_path = "/tmp/contact_form_${random_uuid.contact_form.result}.py"
}

# Resources ===================================================================
resource "random_uuid" "contact_form" {}

resource "aws_lambda_function" "contact_form" {
  description      = "Python function to send an email via AWS SES."
  function_name    = "contact_form"
  s3_bucket        = var.artifact_bucket_id
  s3_key           = aws_s3_object.lambda_contact_form.key
  runtime          = "python3.10"
  handler          = "handler.lambda_handler"
  source_code_hash = data.archive_file.lambda_contact_form.output_base64sha256
  role             = aws_iam_role.lambda_contact_form.arn

  environment {
    variables = {
      DEFAULT_RECIPIENT = local.email_headers["default_recipient"]
      DEFAULT_SENDER    = local.email_headers["default_sender"]
    }
  }
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.contact_form.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = aws_api_gateway_deployment.contact_form.execution_arn
}

# Outputs =====================================================================
/*
output "aws_lambda_function_invoke_arn" {
  description = "Invocation URL for the Lambda function."
  value       = aws_lambda_function.contact_form.invoke_arn
  sensitive   = false
}
*/
