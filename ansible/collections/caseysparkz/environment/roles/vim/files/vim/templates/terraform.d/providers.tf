/* Terraform and Providers */

// Terraform ===================================================================
terraform {
  required_version = "~> 1.2.3"

  required_providers {
    /*
    random = {
      source  = "hashicorp/random"
      //version = "~> x.y.z"
    }
    aws = {
      source  = "hashicorp/aws"
      //version = "~> x.y.z"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      //version = "~> x.y.z"
    }
    */
  }

  /*
  backend "s3" {
    bucket  = "com.caseysparkz.tfstate"
    key     = "" // TODO
    region  = "us-west-2"
    encrypt = true
    use_lockfile = true
  }
  */
}

// Data ========================================================================

// Providers ===================================================================
provider "aws" {
  region = var.aws_region

  default_tags { tags = local.common_tags }
}
