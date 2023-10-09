########################################################################################################################
# Docker
#
locals {}

resource "docker_image" "build" { #                                             Build images.
  for_each = local.dockerfiles
  name     = "${local.ecr_registry}/${each.key}"
  triggers = { filehash = filesha1("${local.dockerfile_dir}/${each.key}") } #   If image changed.

  build {
    context      = local.dockerfile_dir
    dockerfile   = each.value
    network_mode = "host"
    label        = { author = local.ecr_admin_email }
  }
}

resource "docker_registry_image" "push" { #                                     Push images.
  depends_on = [docker_image.build]
  for_each   = local.dockerfiles
  name       = "${local.ecr_registry}/${each.key}"
}
