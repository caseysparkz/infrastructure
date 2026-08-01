################################################################################
# Network Manifests
#
# Creates an AWS VPC that LAN networks can be connected to.
#
# Additionally, creates IAM objects (users, policies, groups) needed for the
# pfSense AWS VPC VPN Connection Wizard to run.

locals {
  azs            = [data.aws_availability_zones.this.names[0]]
  public_subnets = [cidrsubnet(var.aws_vpc_cidr, 8, 250)] // Match LAN convention for MGMT subnet/VLAN
}

# Data =========================================================================
data "aws_availability_zones" "this" {
  state = "available"

  filter { // Default zones only
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_iam_policy_document" "vpc_modify" {
  /*
  The actions required by this policy are fairly unrestricted.
  This is an unfortunate consequence of the way AWS VPCs are designed.

  To harden the policy, the following restrictions are applied on its usage:

  * The policy is tightly scoped to the AWS IAM pfSense user.
  * Requests **must** come from a known office public IP.
  * Requests **must** use the pfSense user-agent string.
  */

  statement { // Allow describe VPCs and VPC objects
    sid       = "AllowVpcMutate"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateCustomerGateway",
      "ec2:CreateRoute",
      "ec2:CreateTags",
      "ec2:CreateVpnConnection",
      "ec2:CreateVpnConnectionRoute",
      "ec2:DescribeCustomerGateways",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeRegions",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "ec2:DescribeVpnConnections",
      "ec2:DescribeVpnGateways",
      "ec2:DisableVgwRoutePropagation",
      "ec2:EnableVgwRoutePropagation",
    ]
  }

  statement { // Deny requests from principals other than the pfSense AWS IAM user
    sid       = "DenyUnknownPrincipal"
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    condition {
      test     = "StringNotEquals"
      variable = "aws:username"
      values   = [aws_iam_user.pfsense.name]
    }
  }

  statement { // Deny requests with unrecognized user-agent strings
    sid       = "DenyUnknownUserAgent"
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "aws:UserAgent"
      values   = ["aws-sdk-php/* * OS/FreeBSD#* lang/php#* * *"]
    }
  }
}

# Modules ======================================================================
module "vpc" { // trivy:ignore:AWS-0102 trivy:ignore:AWS-0105
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.6"

  // Misc. Config
  tags             = { Vpc = "${local.namespace}-vpc" } // Global module tags
  instance_tenancy = "default"                          // For all created EC2 instances

  // VPC Config
  name       = "${local.namespace}-vpc"
  create_vpc = true
  vpc_tags   = { Name = "${local.namespace}-vpc" }
  region     = var.aws_region

  // Network Config
  cidr                                = var.aws_vpc_cidr
  azs                                 = local.azs
  create_igw                          = true
  create_egress_only_igw              = true
  create_multiple_intra_route_tables  = false
  create_multiple_public_route_tables = false
  create_private_nat_gateway_route    = false
  igw_tags                            = { Name = "${local.namespace}-igw" }
  private_subnets                     = []
  public_subnets                      = local.public_subnets
  enable_nat_gateway                  = false
  enable_dns_hostnames                = true
  enable_ipv6                         = false
  manage_default_route_table          = false // This is managed by our pfSense controllers
  manage_default_network_acl          = true
  manage_default_security_group       = true
  manage_default_vpc                  = false // This is the default VPC for our org. Don't touch it.
  map_public_ip_on_launch             = false
  propagate_public_route_tables_vgw   = true
  default_route_table_name            = "${local.namespace}-vpc-rtb"
  default_route_table_tags            = { Name = "${local.namespace}-vpc-rtb" }
  //default_route_table_propagating_vgws              = []
  public_route_table_tags                           = { Name = "${local.namespace}-rtb-public" }
  public_subnet_private_dns_hostname_type_on_launch = "resource-name"
  public_subnet_names = [
    for index, _ in local.public_subnets :
    "${local.namespace}-subnet-public-${index}"
  ]

  // Network ACLs/SGs Config
  default_network_acl_name = "${local.namespace}-vpc-acl"
  default_network_acl_ingress = [
    { // Allow all ingress # FIXME
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      protocol   = "-1"
      rule_no    = 100
      to_port    = 0
    }
  ]
  default_network_acl_egress = [
    { // Allow all IPv4 egress
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      protocol   = "-1"
      rule_no    = 100
      to_port    = 0
    }
  ]
  default_network_acl_tags     = { Name = "${local.namespace}-vpc-acl" }
  public_dedicated_network_acl = true
  public_inbound_acl_rules = [ // TODO
    {                          // Allow all inbound traffic
      cidr_block  = "0.0.0.0/0"
      from_port   = 0
      protocol    = "-1"
      rule_action = "allow"
      rule_number = 100
      to_port     = 0
    }
  ]
  public_outbound_acl_rules = [
    { // Allow all outbound traffic
      cidr_block  = "0.0.0.0/0"
      from_port   = 0
      protocol    = "-1"
      rule_action = "allow"
      rule_number = 100
      to_port     = 0
    }
  ]
  public_acl_tags = { Name = "${local.namespace}-acl-public" }

  default_security_group_name = "${local.namespace}-sg-default"
  //default_security_group_egress  = [] // TODO
  //default_security_group_ingress = [] // TODO
  default_security_group_tags = { Name = "${local.namespace}-sg-default" }

  default_vpc_name                 = "${local.namespace}-vpc"
  default_vpc_enable_dns_support   = true
  default_vpc_enable_dns_hostnames = true
  default_vpc_tags                 = { Name = "${local.namespace}-vpc" }

  // VPN Config
  enable_vpn_gateway = true
  vpn_gateway_az     = local.azs[0]
  vpn_gateway_tags   = { Name = "${local.namespace}-vgw" }

  // CloudWatch/Flow Log Config
  enable_flow_log                      = true
  enable_network_address_usage_metrics = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true
  flow_log_cloudwatch_log_group_class  = "INFREQUENT_ACCESS"
  //flow_log_cloudwatch_log_group_kms_key_id        = "" // TODO
  flow_log_cloudwatch_log_group_name_prefix       = "/aws/${local.namespace}-vpc-flowlog/"
  flow_log_cloudwatch_log_group_name_suffix       = ""
  flow_log_cloudwatch_log_group_retention_in_days = 365
  flow_log_cloudwatch_log_group_skip_destroy      = false
  flow_log_destination_type                       = "cloud-watch-logs"
  flow_log_file_format                            = "plain-text"
  flow_log_traffic_type                           = "ALL"
  vpc_flow_log_iam_policy_name                    = "${local.namespace}-iam-policy-flowlogtocloudwatch"
  vpc_flow_log_iam_policy_use_name_prefix         = false
  vpc_flow_log_iam_role_name                      = "${local.namespace}-iam-role-vpcflowlog"
  vpc_flow_log_iam_role_path                      = "/system/com/caseysparkz/"
  vpc_flow_log_iam_role_use_name_prefix           = false
  vpc_flow_log_tags                               = { Name = "${local.namespace}-vpc-flowlog" }
}

# Resources ====================================================================
## IAM -------------------------------------------------------------------------
resource "aws_iam_user" "pfsense" {
  name          = "${local.namespace}-iam-user-pfsense"
  force_destroy = true
  path          = "/system/com/caseysparkz/"
  tags          = { Name = "${local.namespace}-iam-user-pfsense" }
}

resource "aws_iam_group" "pfsense" { // trivy:ignore:AWS-0123
  name = "${local.namespace}-iam-group"
  path = "/system/com/caseysparkz/"
}

resource "aws_iam_user_group_membership" "pfsense" {
  user   = aws_iam_user.pfsense.name
  groups = [aws_iam_group.pfsense.name]
}

resource "aws_iam_access_key" "pfsense" {
  user   = aws_iam_user.pfsense.name
  status = var.enable_pfsense_iam_access_key ? "Active" : "Inactive"

  lifecycle { create_before_destroy = true }
}

resource "aws_iam_policy" "allow_vpc_modify" {
  name        = "${local.namespace}-iam-policy-allowvpcmodifybypfsense"
  description = "Allows the ${aws_iam_user.pfsense.name} IAM user to modify the VPC."
  policy      = data.aws_iam_policy_document.vpc_modify.json
  tags        = { Name = "${local.namespace}-iam-policy" }
}

resource "aws_iam_group_policy_attachment" "pfsense_vpc_modify" {
  group      = aws_iam_group.pfsense.name
  policy_arn = aws_iam_policy.allow_vpc_modify.arn
}

## Networking ------------------------------------------------------------------
resource "aws_default_route_table" "this" {
  default_route_table_id = module.vpc.default_route_table_id
  tags                   = { Name = "${local.namespace}-vpc-rtb" }
  propagating_vgws       = [] // pfSense Wizard will handle these

  lifecycle { ignore_changes = [propagating_vgws] } // Managed by pfSense
}

# Outputs ======================================================================
output "vpc_region" {
  description = "AWS region of the created VPC."
  sensitive   = false
  value       = var.aws_region
}

output "vpc_id" {
  description = "ID of the created VPC."
  sensitive   = false
  value       = module.vpc.vpc_id
}

output "pfsense_vpc_vpn_wizard_credentials" {
  description = "Values to use when configuring the AWS VPC VPN connection wizard in pfSense."
  sensitive   = true
  value = {
    aws_access_key_id     = var.enable_pfsense_iam_access_key ? aws_iam_access_key.pfsense.id : ""
    aws_secret_access_key = var.enable_pfsense_iam_access_key ? aws_iam_access_key.pfsense.secret : ""
    assume_role_arn       = null
    partition             = "AWS Public Cloud"
  }
}
