###############################################################################
# Outputs
#

## Lambda =====================================================================
output "aws_lambda_function_name" {
  description = "Name of the contact form Lambda function."
  value       = aws_lambda_function.contact_form.function_name
  sensitive   = false
}

## S3 =========================================================================
output "aws_s3_bucket_endpoint" {
  description = "Bucket endpoint"
  value       = aws_s3_bucket_website_configuration.www_site.website_endpoint
  sensitive   = false
}

output "aws_s3_bucket_uri" {
  description = "URI of the S3 bucket (as expected by the AWS CLI)."
  value       = "s3://${aws_s3_bucket.www_site.id}/"
  sensitive   = false
}

## API Gateway ================================================================
output "aws_apigateway_base_url" {
  description = "Base URL for the contact form API gateway stage."
  value       = local.apigateway_url
  sensitive   = false
}

output "aws_apigateway_contact_form_uri" {
  description = "URI of the contact form page."
  value       = local.contact_form_endpoint
  sensitive   = false
}
