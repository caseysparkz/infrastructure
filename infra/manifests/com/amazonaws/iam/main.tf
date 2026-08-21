/*
Main

Author:       Casey Sparks
Date:         July 30, 2026
Description:  Global AWS IAM roles, policies, and permissions boundaries.
*/

locals {
  aws_account_id = data.aws_caller_identity.this.account_id
  environment    = "global"
  project        = "aws"
  application    = "iam"
  namespace      = "${local.environment}-${local.project}-${local.application}"
  common_tags = {
    Application = local.application
    Environment = local.environment
    ManagedBy   = "terraform"
    Project     = local.project
    Repo        = "github.com/caseysparkz/monorepo"
    RepoPath    = "infra/manifests/com/amazonaws/iam"
  }
}

// Data ========================================================================
data "aws_caller_identity" "this" {}

// Modules =====================================================================
module "aws_resourcegroups_group" {
  source              = "../../../../modules/aws_resourcegroup_by_tagset"
  resource_group_name = "${local.namespace}-rg"
  common_tags         = local.common_tags
}
