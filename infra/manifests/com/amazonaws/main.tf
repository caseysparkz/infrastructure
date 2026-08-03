################################################################################
# Main
#
# Author:       Casey Sparks
# Date:         July 28, 2026
# Description:  Minimal security configurations and organization policies.

locals {
  aws_account_id = data.aws_caller_identity.this.account_id
  environment    = "all"
  project        = "aws"
  application    = "config"
  namespace      = "${local.environment}-${local.project}-${local.application}"
  common_tags = {
    Application = local.application
    Environment = local.environment
    ManagedBy   = "terraform"
    Namespace   = local.namespace
    Project     = local.project
    Repo        = "github.com/caseysparkz/monorepo"
    RepoPath    = "infra/manifests/com/amazonaws"
  }
}

# Data =========================================================================
data "aws_caller_identity" "this" {}

data "terraform_remote_state" "this" {
  backend = "s3"
  config = {
    bucket       = "com.caseysparkz.tfstate"
    key          = "com/caseysparkz.tfstate"
    region       = "us-west-2"
    use_lockfile = true
    encrypt      = true
  }
}

# Modules ======================================================================
module "aws_resourcegroups_group" {
  source              = "../../../modules/aws_resourcegroup_by_tagset"
  resource_group_name = "${local.namespace}-rg"
  common_tags         = local.common_tags
}

# Resources ====================================================================
resource "aws_ebs_encryption_by_default" "this" {
  enabled = true // Require EBS encryption
}

resource "aws_ec2_instance_metadata_defaults" "this" {
  http_tokens = "required" // Require IMDSv2
}
