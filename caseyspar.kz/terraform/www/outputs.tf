########################################################################################################################
# Outputs
#

output "aws_s3_bucket_endpoint" {
  description = "Bucket endpoint"
  value       = aws_s3_bucket_website_configuration.www_site.website_endpoint
}

output "aws_s3_bucket_uri" {
  description = "URI of the S3 bucket (as expected by the AWS CLI)."
  value       = "s3://${aws_s3_bucket.www_site.id}/"
}

output "cloudflare_zone_id" {
  description = "ID of the Cloudflare zone."
  value       = data.cloudflare_zones.domain.zones[0].id
}
