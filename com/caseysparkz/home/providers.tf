################################################################################
# Terraform and Providers
#

locals {
  aws_account_id = data.aws_caller_identity.this.id
  routeros_credentials = {
    ap01 = jsondecode(ephemeral.aws_secretsmanager_secret_version.routeros_ap01_credentials.secret_string)
    sw01 = jsondecode(ephemeral.aws_secretsmanager_secret_version.routeros_sw01_credentials.secret_string)
  }
}

# Terraform ====================================================================
terraform {
  required_version = ">= 1.13.3, < 2.0.0"

  backend "s3" {
    bucket       = "com.caseysparkz.tfstate"
    key          = "com/caseysparkz/home.tfstate"
    region       = "us-west-2"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28.0"
    }
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "~> 1.98.0"
    }
  }
}

# Providers ====================================================================
provider "aws" { region = var.aws_region }

provider "routeros" {
  alias          = "sw01"
  hosturl        = "https://sw01.${var.lan_domain}:${var.https_port}"
  username       = local.routeros_credentials.sw01.username
  password       = local.routeros_credentials.sw01.password
  ca_certificate = "${path.module}/files/home.caseysparkz.com-fw01-CA.crt"
  insecure       = false
}

provider "routeros" {
  alias          = "ap01"
  hosturl        = "https://ap01.${var.lan_domain}:${var.https_port}"
  username       = local.routeros_credentials.ap01.username
  password       = local.routeros_credentials.ap01.password
  ca_certificate = "${path.module}/files/home.caseysparkz.com-fw01-CA.crt"
  insecure       = false
}

# Data & Ephemerals ============================================================
# AWS --------------------------------------------------------------------------
data "aws_caller_identity" "this" {}

# ap01 Credentials -------------------------------------------------------------
data "aws_secretsmanager_secret" "routeros_ap01_credentials" {
  arn = "arn:aws:secretsmanager:${var.aws_region}:${local.aws_account_id}:secret:routeros/ap01_credentials"
}

ephemeral "aws_secretsmanager_secret_version" "routeros_ap01_credentials" {
  secret_id = data.aws_secretsmanager_secret.routeros_ap01_credentials.id
}

# sw01 Credentials -------------------------------------------------------------
data "aws_secretsmanager_secret" "routeros_sw01_credentials" {
  arn = "arn:aws:secretsmanager:${var.aws_region}:${local.aws_account_id}:secret:routeros/sw01_credentials"
}

ephemeral "aws_secretsmanager_secret_version" "routeros_sw01_credentials" {
  secret_id = data.aws_secretsmanager_secret.routeros_sw01_credentials.id
}
