###############################################################################
# Terraform and Providers
#

## Terraform ==================================================================
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.33"
    }
  }
}
