################################################################################
# Terraform and Providers
#

# Terraform --------------------------------------------------------------------
terraform {
  required_version = ">= 1.10.5, < 2.0.0"

  backend "s3" {
    bucket       = "com.caseysparkz.tfstate"
    key          = "com/caseysparkz/eks.tfstate"
    region       = "us-west-2"
    use_lockfile = true
    encrypt      = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 3.0.1"
    }
  }
}

# Providers --------------------------------------------------------------------
provider "aws" {
  region = var.aws_region

  default_tags { tags = local.common_tags }
}

provider "kubernetes" {
  host                   = aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.this.name]
  }
}
