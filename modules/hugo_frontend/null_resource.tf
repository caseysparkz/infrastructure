###############################################################################
# Terraform Data, Null Resources, and Local Executions
#
locals {
  contact_form_template = "${var.hugo_dir}/content/contactForm.js.tftpl"
  build_hash = sha256(join( #                                                   Check if Hugo build has changed.
    "",
    [
      for file in setsubtract(fileset(var.hugo_dir, "*"), fileset("${var.hugo_dir}/public", "*")) :
      filesha1("${var.hugo_dir}/${file}")
    ]
  ))
}

# Resources ===================================================================
resource "local_file" "contact_form_js" {
  filename = replace(local.contact_form_template, ".tftpl", "")
  content = templatefile(
    local.contact_form_template,
    {
      execution_url = aws_api_gateway_deployment.contact_form.invoke_url
    }
  )
}

/*
The following resources will be redeployed **any** time a file in ${var.hugo_dir} is added, removed, or changed, or
(more specifically) any time the value of ${local.build_hash} changes.
*/

resource "null_resource" "npm_install" {
  triggers = {
    build_hash = local.build_hash
  }

  provisioner "local-exec" {
    command     = "npm install"
    working_dir = var.hugo_dir
  }
}

resource "null_resource" "compile_pages" {
  triggers = {
    build_hash = local.build_hash
  }

  depends_on = [
    null_resource.npm_install,
    local_file.contact_form_js,
  ]
  provisioner "local-exec" {
    command     = "hugo"
    working_dir = var.hugo_dir
  }
}

resource "null_resource" "deploy_site" {
  triggers = {
    build_hash = local.build_hash
  }

  depends_on = [
    aws_s3_bucket.www_site,
    null_resource.compile_pages,
  ]
  provisioner "local-exec" {
    command = "aws s3 sync --delete ${var.hugo_dir}/public/ s3://${aws_s3_bucket.www_site.id}"
  }
}
