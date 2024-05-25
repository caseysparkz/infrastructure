###############################################################################
# Terraform Data, Null Resources, and Local Executions
#
# Notes:  There's a LOT of REAL janky shit and filesystem checks in this module
#         that allow me to locally:
#             * Install node modules when ${var.hugo_dir}/package.json changes.
#             * Build the site when any build pages change.
#             * Deploy the site if any file in ${var.hugo_dir}/public/ changes.
#
#         These are emphatically **not** best pracices.
#         Always remember to ask an adult for help when using scissors.

locals {
  contact_form_js_template = "${var.hugo_dir}/content/contactForm.js.tftpl"
  build_hash = sha256(join( #                                                   Check if Hugo build files have changed.
    "",
    [
      for file in setsubtract(
        fileset(var.hugo_dir, "*"),
        fileset("${var.hugo_dir}/public", "*")
      ) :
      filesha1("${var.hugo_dir}/${file}")
    ]
  ))
  node_modules_hash = sha256(join( #                                            Check if node reqs/modules have changed.
    "",
    [
      for file in setunion(fileset(var.hugo_dir, "node_modules/*"), fileset(var.hugo_dir, "package.json")) :
      filesha1("${var.hugo_dir}/${file}")
    ]
  ))
}

# Resources ===================================================================
resource "local_file" "contact_form_js" {
  filename        = replace(local.contact_form_js_template, ".tftpl", "")
  file_permission = "0770"
  content = templatefile(
    local.contact_form_js_template,
    {
      execution_url = aws_api_gateway_deployment.contact_form.invoke_url
    }
  )
}

resource "null_resource" "npm_install" {
  triggers = {
    build_hash = local.node_modules_hash
  }

  provisioner "local-exec" {
    command     = "npm install"
    working_dir = var.hugo_dir
  }
}

resource "null_resource" "compile_pages" {
  triggers = {
    build_hash = local.build_hash
    contact_js = local_file.contact_form_js.content_sha1
  }
  depends_on = [
    local_file.contact_form_js,
    null_resource.npm_install,
  ]

  provisioner "local-exec" {
    command     = "hugo"
    working_dir = var.hugo_dir
  }
}

resource "null_resource" "deploy_site" {
  triggers = null_resource.compile_pages.triggers
  depends_on = [
    aws_s3_bucket.www_site,
    null_resource.compile_pages,
  ]

  provisioner "local-exec" {
    command = "aws s3 sync --delete ${var.hugo_dir}/public/ s3://${aws_s3_bucket.www_site.id}"
  }
}
