###############################################################################
# Main
#

## Locals =====================================================================
locals {
  common_tags = {
    service = "ecr"
  }
  dockerfiles     = fileset("${var.dockerfile_dir}/", "*")
  ecr_admin_email = "ecr_admin@${var.root_domain}"
  ecr_repositories = [
    for f in local.dockerfiles : "${local.ecr_registry_url}/${replace(f, "/:.*$/", "")}"
  ]
}
