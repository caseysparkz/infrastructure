###############################################################################
# Docker
#

## Resources ==================================================================
resource "null_resource" "docker_login" { #                                     Log in to ECR
  provisioner "local-exec" {
    command = "aws ecr get-login-password | docker login ${local.ecr_registry_url} -u AWS --password-stdin"
  }
}

resource "null_resource" "docker_compose_build" { #                             Build images.
  for_each = local.docker_compose_files
  depends_on = [
    aws_ecr_repository.ecr,
    null_resource.docker_login
  ]
  triggers = {
    filehash = filesha1("${var.docker_compose_dir}/${each.key}") #              If dockerfile has changed.
  }

  provisioner "local-exec" {
    working_dir = var.docker_compose_dir
    command     = "docker compose -f ${each.key} build"
    quiet       = true
  }
}

resource "docker_registry_image" "push" { #                                     Push images.
  for_each = toset([for f in local.docker_compose_files : trimsuffix(f, ".docker-compose.yml")])
  depends_on = [
    aws_ecr_repository.ecr,
    null_resource.docker_login,
    null_resource.docker_compose_build,
  ]
  name = "${local.ecr_registry_url}/${each.key}"
}
