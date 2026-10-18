/* Terraform and Providers */

terraform {
  required_version = ">= 1.16.6, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.41.0, < 7.0.0"
    }
  }

  backend "s3" {
    region       = "us-west-2"
    bucket       = "com.caseysparkz.tfstate"
    key          = "tfstate.tfstate"
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags { tags = local.common_tags }
}
