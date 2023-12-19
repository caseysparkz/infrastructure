###############################################################################
# Terraform and Providers
#

## Terraform ==================================================================
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.17.0"
    }
  }
}
