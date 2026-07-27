################################################################################
# Network
#

locals {
  azs = slice(data.aws_availability_zones.this.names, 0, 3)
}

# Data =========================================================================
data "aws_availability_zones" "this" {
  state = "available"

  filter { # Default zones only
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Modules ======================================================================
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.6"

  name                 = "${local.namespace}-vpc"
  cidr                 = var.vpc_cidr
  azs                  = local.azs
  private_subnets      = [for subnet_index in range(length(local.azs)) : cidrsubnet(var.vpc_cidr, 8, subnet_index)]
  public_subnets       = [] //[for subnet_index in range(length(local.azs)) : cidrsubnet(var.vpc_cidr, 8, 254 - subnet_index)]
  enable_nat_gateway   = false
  enable_dns_hostnames = true
  tags                 = { Name = "${local.namespace}-vpc" }
  vpc_tags             = { Name = "${local.namespace}-vpc" }
  //public_subnet_tags = { "kubernetes/role/elb" = "1" }
  private_subnet_tags = { "kubernetes/role/internal-elb" = "1" }
}

# Outputs ======================================================================
