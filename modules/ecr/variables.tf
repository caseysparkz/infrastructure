###############################################################################
# Variables
#

variable "root_domain" {
  type        = string
  description = "Root domain of the infrastructure."
  sensitive   = false
}

variable "dockerfile_dir" {
  type        = string
  description = "Absolute path to the dir containing the Dockerfiles."
  sensitive   = false
}
