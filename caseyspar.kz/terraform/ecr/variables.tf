########################################################################################################################
# Variables
#

variable "ecr_repository_names" {
  description = "List of ECR repository names to create."
  type = list(string)
  sensitive = false
}
