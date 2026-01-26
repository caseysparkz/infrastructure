###############################################################################
# Variables
#

variable "root_domain" {
  description = "Root domain of the deployed infrastructure."
  type        = string
  sensitive   = false
  default     = "caseysparkz.com"
}

variable "aws_region" {
  description = "AWS region to deploy the infrastructure to."
  type        = string
  sensitive   = false
  default     = "us-west-2"
}

variable "eks_version" {
  description = "Kubernetes version to run in EKS."
  type        = string
  sensitive   = false
  default     = "1.31"
}

variable "environment" {
  description = "Deployment environment for the manifests."
  type        = string
  sensitive   = false

  validation {
    condition     = var.environment == terraform.workspace
    error_message = "'var.environment' must match Terraform workspace."
  }
}

variable "aws_kms_key_id" {
  description = "ID of the KMS key used to encrypt resources."
  type        = string
  sensitive   = false
}
