###############################################################################
# Docker
#

## Resources ==================================================================
resource "docker_image" "build" { #                                             Build images.
  for_each   = local.dockerfiles
  depends_on = [aws_ecr_repository.ecr]
  name       = "${local.ecr_registry_url}/${each.key}"
  triggers   = { filehash = filesha1("${local.dockerfile_dir}/${each.key}") } # If dockerfile has changed.

  build {
    context      = local.dockerfile_dir
    dockerfile   = each.key
    network_mode = "host"
    label        = { author = local.ecr_admin_email }
  }
}

resource "null_resource" "docker_login" { #                                     Log in to ECR
  provisioner "local-exec" {
    command = "aws ecr get-login-password | docker login -u AWS --password-stdin ${local.ecr_registry_url}"
  }
}

resource "docker_registry_image" "push" { #                                     Push images.
  for_each = local.dockerfiles
  depends_on = [
    aws_ecr_repository.ecr,
    docker_image.build,
    null_resource.docker_login,
  ]
  name = "${local.ecr_registry_url}/${each.key}"
}
