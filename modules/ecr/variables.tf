###############################################################################
# Variables
#

variable "root_domain" {
  type        = string
  description = "Root domain of the infrastructure."
  sensitive   = false
}

variable "docker_compose_dir" {
  type        = string
  description = "Absolute path to the dir containing the docker-compose files."
  sensitive   = false
}
