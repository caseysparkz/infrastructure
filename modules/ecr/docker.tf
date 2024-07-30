###############################################################################
# Docker
#

## Resources ==================================================================
resource "null_resource" "docker_login" { #                                     Log in to ECR
  provisioner "local-exec" {
    command = "aws ecr get-login-password | docker login ${local.ecr_registry_url} -u AWS --password-stdin"
  }
}

resource "docker_image" "build" { #                                             Build images.
  for_each = local.dockerfiles
  depends_on = [
    aws_ecr_repository.ecr,
    null_resource.docker_login
  ]
  name     = "${local.ecr_registry_url}/${trim(each.key, ".Dockerfile")}"
  triggers = { filehash = filesha1("${var.dockerfile_dir}/${each.key}") } #   If dockerfile has changed.

  build {
    context      = var.dockerfile_dir
    dockerfile   = each.key
    network_mode = "host"
    label        = { author = local.ecr_admin_email }
  }
}

resource "docker_registry_image" "push" { #                                     Push images.
  for_each = local.dockerfiles
  depends_on = [
    aws_ecr_repository.ecr,
    docker_image.build,
    null_resource.docker_login,
  ]
  name = "${local.ecr_registry_url}/${trim(each.key, ".Dockerfile")}"
}
