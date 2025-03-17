###############################################################################
# Terraform and Providers
#

## Terraform ==================================================================
terraform {
  required_version = ">= 1.10.5, < 2.0.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.1.0"
    }
  }
}
