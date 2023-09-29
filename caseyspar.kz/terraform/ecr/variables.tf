########################################################################################################################
# Variables
#

variable "ecr_repository_names" {
  description = "List of ECR repository names to create."
  type        = list(string)
  sensitive   = false

  validation {
    condition = alltrue([
      for v in var.ecr_repository_names : can(regex("^[a-zA-Z0-9_./]*$", v))
    ])
    error_message = "ECR repository name contains invalid characters [a-zA-Z0-9-_./]."
  }
}
