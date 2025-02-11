###############################################################################
# Terraform and Providers
#

terraform {
  required_version = "~> 1.10.5"

  backend "s3" {
    region       = "us-west-2"
    bucket       = "caseyspar.kz-tfstate"
    key          = "tfstate.tfstate"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.86.1"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      terraform   = true
      application = "tfstate"
    }
  }
}
