################################################################################
# AWS Subnets
#

locals {
  subnets = {
    a = "10.199.1.0/24",
    b = "10.199.2.0/24",
    c = "10.199.3.0/24",
    d = "10.199.4.0/24",
  }
}

# Resources --------------------------------------------------------------------
resource "aws_vpc" "this" {
  cidr_block                           = "10.199.0.0/16"
  instance_tenancy                     = "default"
  enable_dns_support                   = true
  enable_network_address_usage_metrics = true
  tags                                 = { Name = "${local.namespace}-vpc" }
}

resource "aws_subnet" "this" {
  count             = length(values(local.subnets))
  vpc_id            = aws_vpc.this.id
  cidr_block        = values(local.subnets)[count.index]
  availability_zone = "${var.aws_region}${keys(local.subnets)[count.index]}"
  tags              = { Name = "${local.namespace}-subnet-0${count.index}" }
}
