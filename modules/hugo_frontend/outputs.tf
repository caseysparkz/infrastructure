###############################################################################
# Outputs
#

## API Gateway ================================================================
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

/*
## Lambda =====================================================================
output "aws_lambda_function_invoke_arn" {
  description = "Invocation URL for the Lambda function."
  value       = aws_lambda_function.contact_form.invoke_arn
  sensitive   = false
}
*/
