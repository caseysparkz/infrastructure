###############################################################################
# Terraform and Providers
#

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}

## Terraform ==================================================================
terraform {
  required_version = ">= 1.10.5, < 2.0.0"

  backend "s3" { #                                                              ./modules/tfstate_backend
    bucket       = "caseyspar.kz-tfstate"
    key          = "caseysparkz.com.tfstate"
    region       = "us-west-2"
    use_lockfile = true
    encrypt      = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.94.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.1.0"
    }
  }
}

## Providers ==================================================================
provider "aws" { #                                                              AWS
  region = var.aws_region

  default_tags {
    tags = {
      terraform = true
      domain    = var.root_domain
    }
  }
}

provider "cloudflare" { #                                                       Cloudflare
  api_token = data.aws_secretsmanager_secret_version.cloudflare_token.secret_string
}

## Data =======================================================================
data "aws_caller_identity" "current" {} #                                       AWS

data "aws_secretsmanager_secret" "cloudflare_token" {
  arn = "arn:aws:secretsmanager:${var.aws_region}:${local.aws_account_id}:secret:cloudflare/api_token"
}

data "aws_secretsmanager_secret_version" "cloudflare_token" {
  secret_id = data.aws_secretsmanager_secret.cloudflare_token.id
}

## Outputs ====================================================================
output "aws_region" {
  description = "Region to which tf config is deployed."
  value       = var.aws_region
  sensitive   = false
}
