###############################################################################
# Main
#

## Locals =====================================================================
locals {
  common_tags          = merge(var.common_tags, { service = "ecr" })
  docker_compose_files = fileset("${var.docker_compose_dir}/", "*.yml")
  ecr_admin_email      = "ecr_admin@${var.root_domain}"
  ecr_repositories     = [for f in local.docker_compose_files : "${local.ecr_registry_url}/${replace(f, "/:.*$/", "")}"]
}
