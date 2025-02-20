###############################################################################
# Terraform and Providers
#
locals {}

## Terraform ==================================================================
terraform {
  required_version = "~> 1.10.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.88.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }
}

## Providers ==================================================================
provider "docker" { #                                                           Docker.
  registry_auth {
    address  = local.ecr_authorization_token.proxy_endpoint
    username = local.ecr_authorization_token.user_name
    password = local.ecr_authorization_token.password
  }
}
