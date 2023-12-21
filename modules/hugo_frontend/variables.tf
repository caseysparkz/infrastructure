###############################################################################
# Variables.
#

# API Gateway =================================================================
variable "api_gateway_id" {
  description = "ID of the AWS API gateway."
  type        = string
  sensitive   = false
}

variable "api_gateway_root_resource_id" {
  description = "ID of the AWS API gateway's root resource."
  type        = string
  sensitive   = false
}

variable "api_gateway_execution_arn" {
  description = "Execution ARN of the AWS API gateway."
  type        = string
  sensitive   = false
}

# Lambda ======================================================================
variable "artifact_bucket_id" {
  description = "ID of the S3 bucket in which lambda functions are kept."
  type        = string
  sensitive   = false
}

# Misc. =======================================================================
variable "root_domain" {
  description = "Root domain of Terraform infrastructure."
  type        = string
  sensitive   = false
}

variable "subdomain" {
  description = "Subdomain of Terraform infrastructure."
  type        = string
  sensitive   = false
}

variable "site_title" {
  description = "Title of the website."
  type        = string
  sensitive   = false
}

variable "hugo_dir" {
  description = "Absolute path of the Hugo directory."
  type        = string
  sensitive   = false
}
