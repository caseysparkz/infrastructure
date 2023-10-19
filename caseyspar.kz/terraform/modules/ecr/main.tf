###############################################################################
# Main
#

## Locals =====================================================================
locals {
  common_tags     = {
    service = "ecr"
  }
  dockerfile_dir  = "${path.module}/dockerfiles"
  dockerfiles     = fileset("${local.dockerfile_dir}/", "*")
  ecr_admin_email = "ecr_admin@${var.root_domain}"
  ecr_registry = replace(
    data.aws_ecr_authorization_token.token.proxy_endpoint,
    "https://",
    ""
  )
  ecr_repositories = [
    for f in local.dockerfiles : "${local.ecr_registry}/${replace(f, "/:.*$/", "")}"
  ]
}
