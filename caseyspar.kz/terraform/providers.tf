###############################################################################
# Terraform and Providers
#

## Terraform ==================================================================
terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.17.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
  }

  backend "s3" { #                                                              ./infrastructure/tf_backend_s3
    bucket  = "caseyspar.kz-tfstate"
    key     = "caseysparkz.tfstate"
    region  = "us-west-2"
    encrypt = true
  }
}

## Providers ==================================================================
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  default_tags {
    tags = {
      terraform = true
      domain    = var.root_domain
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
