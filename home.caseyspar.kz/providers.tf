###############################################################################
# Terraform and Providers
#

## Terraform ==================================================================
terraform {
  required_version = "~> 1.9"

  required_providers {
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "1.56.0"
    }
  }

  /*
  backend "s3" {
    bucket  = ""
    key     = ""
    region  = ""
    encrypt = true
  }
  */
}

## Providers ==================================================================
provider "routeros" {
  hosturl        = var.routeros_hostname
  username       = var.routeros_username
  password       = var.routeros_password
  ca_certificate = var.routeros_ca_certificate
  insecure       = false
}
