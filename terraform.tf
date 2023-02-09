terraform {
  cloud {
    organization = "caseysparkz"
    workspaces {
      name = "caseyspar_kz"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.53.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  # Configuration options
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
