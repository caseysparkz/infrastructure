###############################################################################
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

variable "common_tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  sensitive   = false
  default     = { terraform = true }
}
