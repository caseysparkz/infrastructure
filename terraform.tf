terraform {
  cloud {
    organization = "caseysparkz"
    workspaces {
      name = "caseyspar_kz"
    }
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
