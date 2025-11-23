###############################################################################
# Terraform and Providers
#

terraform {
  required_version = ">= 1.10.5, < 2.0.0"

  backend "s3" {
    region       = "us-west-2"
    bucket       = "com.caseysparkz.tfstate"
    key          = "tfstate.tfstate"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.93.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      terraform   = true
      application = "terraform"
    }
  }
}
