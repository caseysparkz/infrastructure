################################################################################
# Terraform and Providers
#

# Terraform ====================================================================
terraform {
  required_version = ">= 1.10.5, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.94.0,<6.0.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = ">=3.0.2,<4.0.0"
    }
  }
}

# Providers ====================================================================
provider "docker" {
  registry_auth {
    address  = local.ecr_authorization_token.proxy_endpoint
    username = local.ecr_authorization_token.user_name
    password = local.ecr_authorization_token.password
  }
}
