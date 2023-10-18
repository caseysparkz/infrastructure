###############################################################################
# Outputs
#

## S3 =========================================================================
output "aws_s3_bucket_endpoint" {
  description = "Bucket endpoint"
  value       = aws_s3_bucket_website_configuration.www_site.website_endpoint
  sensitive   = false
}

output "aws_s3_bucket_id" {
  description = "ID of the S3 bucket (as expected by the AWS CLI)."
  value       = aws_s3_bucket.www_site.id
  sensitive   = false
}

## API Gateway ================================================================
output "aws_api_gateway_stage_invoke_url" {
  description = "Invocation URL for the contact form API gateway stage."
  value       = aws_api_gateway_stage.contact_form.invoke_url
  sensitive   = false
}

## Lambda =====================================================================
output "aws_lambda_function_invoke_arn" {
  description = "Invocation URL for the Lambda function."
  value       = aws_lambda_function.contact_form.invoke_arn
  sensitive   = false
}

output "aws_lambda_function_url" {
  description = "URL for the Lambda function."
  value       = aws_lambda_function_url.contact_form.function_url
  sensitive   = false
}
