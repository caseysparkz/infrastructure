###############################################################################
# Terraform and Providers
#
locals {}

## Terraform ==================================================================
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8"
    }
  }
}
