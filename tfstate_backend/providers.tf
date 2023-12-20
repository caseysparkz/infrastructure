###############################################################################
# Terraform and Providers
#

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.8.0"
    }
  }
  backend "s3" {
    region = "us-west-2"
    bucket = "caseyspar.kz-tfstate"
    key    = "tfstate.tfstate"
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  default_tags {
    tags = {
      terraform   = true
      application = "tfstate"
    }
  }
}
