########################################################################################################################
# Outputs
#

output "ecr_repository_url" {
  description = "URL of the deployed ECR registry."
  value       = aws_ecr_repository.ecr.repository_url
}
