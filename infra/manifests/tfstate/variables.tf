/* Variables */

variable "aws_region" {
  description = "AWS region to deploy to."
  type        = string
  sensitive   = false
  default     = "us-west-2"
}

variable "bucket_name" {
  description = "Name of the AWS bucket to create."
  type        = string
  sensitive   = false
  default     = "com.caseysparkz.tfstate"
}

variable "admin_principal_arns" {
  description = "IAM principal ARNs permitted to administer the state bucket and its KMS key."
  type        = list(string)
  sensitive   = false
  default = [
    // Admins
    "arn:aws:iam::770088062852:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_b808dbd2325f6b7f",
  ]

  validation {
    condition     = length(var.admin_principal_arns) > 0
    error_message = "At least one admin principal ARN is required (an empty list locks out the KMS key)."
  }

  validation {
    condition = alltrue([
      for arn in var.admin_principal_arns : can(regex("^arn:aws[a-z-]*:(iam|sts)::[0-9]{12}:[^*?]+$", arn))
    ])
    error_message = "Each admin principal must be a literal (non-wildcard) IAM/STS ARN."
  }
}

variable "writer_principal_arns" {
  description = "IAM principal ARNs permitted to read, write, and delete state files in the bucket."
  type        = list(string)
  sensitive   = false
  default = [
    // Admins
    "arn:aws:iam::770088062852:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_b808dbd2325f6b7f",
    // GitHub Actions read/write
    "arn:aws:iam::770088062852:role/prod-iam-githubactions-iam-role-ghaadmin",
  ]

  validation {
    condition     = length(var.writer_principal_arns) > 0
    error_message = "At least one writer principal ARN is required."
  }

  validation {
    condition = alltrue([
      for arn in var.writer_principal_arns : can(regex("^arn:aws[a-z-]*:(iam|sts)::[0-9]{12}:[^*?]+$", arn))
    ])
    error_message = "Each writer principal must be a literal (non-wildcard) IAM/STS ARN."
  }
}

variable "reader_principal_arns" {
  description = "IAM principal ARNs permitted to read state files and write lock files in the bucket."
  type        = list(string)
  sensitive   = false
  default = [
    // GitHub Actions read-only
    "arn:aws:iam::770088062852:role/prod-iam-githubactions-iam-role-ghareadonly",
  ]

  validation {
    condition = alltrue([
      for arn in var.reader_principal_arns : can(regex("^arn:aws[a-z-]*:(iam|sts)::[0-9]{12}:[^*?]+$", arn))
    ])
    error_message = "Each reader principal must be a literal (non-wildcard) IAM/STS ARN."
  }
}
