###############################################################################
# Terraform and Providers
#

## Terraform ==================================================================
terraform {
  required_version = "~> 1.10.5"

  backend "s3" { #                                                              ./modules/tf_backend_s3
    bucket       = "caseyspar.kz-tfstate"
    key          = "caseyspar.kz.tfstate"
    region       = "us-west-2"
    use_lockfile = true
    encrypt      = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.86.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0.0"
    }
  }
}

## Providers ==================================================================
provider "aws" { #                                                              AWS.
  region = var.aws_region

  default_tags {
    tags = {
      terraform = true
      domain    = var.root_domain
    }
  }
}

provider "cloudflare" { api_token = var.cloudflare_api_token } #                Cloudflare.

## Outputs ====================================================================
output "aws_region" {
  description = "Region to which tf config is deployed."
  value       = var.aws_region
  sensitive   = false
}
