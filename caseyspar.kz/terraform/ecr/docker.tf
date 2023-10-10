###############################################################################
# Docker
#

## Resources ==================================================================
resource "docker_image" "build" { #                                             Build images.
  for_each   = local.dockerfiles
  depends_on = [aws_ecr_repository.ecr]
  name       = "${local.ecr_registry}/${each.key}"
  triggers   = { filehash = filesha1("${local.dockerfile_dir}/${each.key}") } # If image changed.

  build {
    context      = local.dockerfile_dir
    dockerfile   = each.key
    network_mode = "host"
    label        = { author = local.ecr_admin_email }
  }
}

resource "docker_registry_image" "push" { #                                     Push images.
  for_each = local.dockerfiles
  depends_on = [
    aws_ecr_repository.ecr,
    docker_image.build
  ]
  name = "${local.ecr_registry}/${each.key}"
}
