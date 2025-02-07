###############################################################################
# Terraform and Providers
#

## Terraform ==================================================================
terraform {
  required_version = "~> 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.86.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.33"
    }
  }

  backend "s3" { #                                                              ./modules/tf_backend_s3
    bucket       = "caseyspar.kz-tfstate"
    key          = "caseyspar.kz.tfstate"
    region       = "us-west-2"
    use_lockfile = true
    encrypt      = true
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

provider "cloudflare" { #                                                       Cloudflare.
  api_token = var.cloudflare_api_token
}

## Outputs ====================================================================
output "aws_region" {
  description = "Region to which tf config is deployed."
  value       = var.aws_region
  sensitive   = false
}
