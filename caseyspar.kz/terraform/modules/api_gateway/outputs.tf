###############################################################################
# Outputs
#

output "aws_api_gateway_id" {
  description = "ID of the AWS API gateway."
  value       = aws_api_gateway_rest_api.subdomain.id
  sensitive   = false
}

output "aws_api_gateway_root_resource_id" {
  description = "ID of the AWS API gateway root resource"
  value       = aws_api_gateway_rest_api.subdomain.root_resource_id
  sensitive   = false
}

output "aws_api_gateway_arn" {
  description = "ARN of the AWS API gateway."
  value       = aws_api_gateway_rest_api.subdomain.arn
  sensitive   = true
}

output "aws_api_gateway_fqdn" {
  description = "ID of the API gateway deployment."
  value       = local.gateway_fqdn
  sensitive   = false
}

output "aws_acm_certificate_id" {
  description = "ID of the AWS ACM certificate used for the API domain."
  value       = aws_acm_certificate.subdomain.id
  sensitive   = false
}

output "aws_acm_certificate_arn" {
  description = "ARN of the AWS ACM certificate used for the API domain."
  value       = aws_acm_certificate.subdomain.arn
  sensitive   = true
}
