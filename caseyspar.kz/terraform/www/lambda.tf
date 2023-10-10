###############################################################################
# AWS Lambda
#

## Locals =====================================================================
locals {
  lambda_dir = "${path.module}/lambda"
  default_email_headers = {
    recipient = "form@${var.subdomain}"
    sender    = "NULL"
    email     = "NULL"
    subject   = "NULL"
    message   = "NULL"
  }
}

## Lambda =====================================================================
# TODO: Fix
# Will redeploy _every_ time.
data "archive_file" "lambda_contact_form" {
  type        = "zip"
  source_file = "${local.lambda_dir}/handler.py"
  output_path = "${local.lambda_dir}/contact_form_handler.zip"
}

resource "aws_s3_object" "lambda_contact_form" {
  bucket = var.artifact_bucket_id
  key    = "contact_form_handler.zip"
  source = data.archive_file.lambda_contact_form.output_path
  etag   = filemd5(data.archive_file.lambda_contact_form.output_path)
}

resource "aws_lambda_function" "contact_form" {
  description      = "Python function to send an email via AWS SES."
  function_name    = "contact_form"
  s3_bucket        = var.artifact_bucket_id
  s3_key           = aws_s3_object.lambda_contact_form.key
  runtime          = "python3.10"
  handler          = "index.test"
  source_code_hash = data.archive_file.lambda_contact_form.output_base64sha256
  role             = aws_iam_role.lambda_contact_form.arn

  environment {
    variables = {
      DEFAULT_RECIPIENT = local.default_email_headers["recipient"]
      DEFAULT_SENDER    = local.default_email_headers["sender"]
      DEFAULT_EMAIL     = local.default_email_headers["email"]
      DEFAULT_SUBJECT   = local.default_email_headers["subject"]
      DEFAULT_MESSAGE   = local.default_email_headers["message"]
    }
  }
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.contact_form.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_contact_form.execution_arn}/*/*"
}
