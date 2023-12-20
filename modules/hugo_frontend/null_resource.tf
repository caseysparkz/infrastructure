###############################################################################
# Null Resources and Local Files/Executions
#
locals {
  hugo_dir = "${path.module}/srv"
  templates = {
    hugo_config  = "${local.hugo_dir}/config.yaml.tftpl"
    contact_page = "${local.hugo_dir}/content/contactForm.js.tftpl"
  }
  srv_dir       = "${local.hugo_dir}/public"
  website_files = fileset(local.srv_dir, "**")
  build_hash = sha256(join( #                                                   If build changes.
    "",
    [
      for file in setsubtract(fileset(local.hugo_dir, "**"), local.website_files) :
      filesha1("${local.hugo_dir}/${file}")
    ]
  ))
  lambda_dir = "${path.module}/lambda"
}

# Data ========================================================================
data "archive_file" "lambda_contact_form" { #                                   TODO. Will redeploy every time.
  type        = "zip"
  source_file = "${path.module}/lambda_contact_form.py"
  output_path = "/tmp/${local.lambda_s3_object_key}"
}

# Resources ===================================================================
resource "local_file" "hugo_config" { # --------------------------------------- Local build.
  filename = replace(local.templates.hugo_config, ".tftpl", "")
  content = templatefile(
    local.templates.hugo_config,
    {
      domain = var.subdomain
      title  = var.root_domain
    }
  )
}

resource "local_file" "contact_page" {
  filename = replace(local.templates.contact_page, ".tftpl", "")
  content = templatefile(
    local.templates.contact_page,
    {
      execution_url = aws_api_gateway_deployment.contact_form.invoke_url
    }
  )
}

resource "null_resource" "npm_install" { #                                      Install dependencies.
  depends_on = [
    local_file.hugo_config,
    local_file.contact_page
  ]
  triggers = {
    build_hash = local.build_hash
  }

  provisioner "local-exec" {
    working_dir = local.hugo_dir
    command     = "npm install"
  }
}

resource "null_resource" "compile_pages" { #                                    Build static site.
  depends_on = [
    local_file.hugo_config,
    local_file.contact_page,
    null_resource.npm_install
  ]
  triggers = {
    build_hash = local.build_hash
  }

  provisioner "local-exec" {
    working_dir = local.hugo_dir
    command     = "hugo"
  }
}

resource "null_resource" "deploy_pages" { #                                     Deploy static site.
  depends_on = [
    null_resource.compile_pages,
    aws_s3_bucket.www_site
  ]
  triggers = {
    build_hash = local.build_hash
  }

  provisioner "local-exec" {
    command = "aws s3 sync --delete ${local.srv_dir} s3://${aws_s3_bucket.www_site.id}"
  }
}
