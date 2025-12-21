################################################################################
# Variables
#

variable "root_domain" {
  description = "Root domain of the infrastructure."
  type        = string
  sensitive   = false
}

variable "docker_compose_dir" {
  description = "Absolute path to the dir containing the docker-compose files."
  type        = string
  sensitive   = false
}

variable "aws_kms_key_arn" {
  description = "ID of the AWS KMS key used to encrypt ECR resources."
  type        = string
  sensitive   = false
}
