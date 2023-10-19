###############################################################################
# AWS Lambda
#

## Resources ==================================================================
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

resource "aws_lambda_function_url" "contact_form" {
  function_name      = aws_lambda_function.contact_form.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["*"]
    expose_headers    = ["*"]
    max_age           = 86400
  }
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.contact_form.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = aws_api_gateway_stage.contact_form.execution_arn
}

/*
resource "aws_lambda_permission" "ses_sendemail" {
  statement_id  = "AllowExecutionFromSES"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.contact_form.function_name
  principal     = "ses.amazonaws.com"
  source_arn    = "arn:aws:ses:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:identity/${var.subdomain}"
}
*/