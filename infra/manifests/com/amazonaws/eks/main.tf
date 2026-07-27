################################################################################
# Main
#

locals {
  //aws_region     = data.aws_region.this.region
  //aws_account_id = data.aws_caller_identity.this.account_id
  environment = "prod"
  project     = "caseysparkz"
  application = "eks"
  namespace   = "${local.environment}-${local.project}-${local.application}"
  common_tags = {
    Application = local.application
    Environment = local.environment
    ManagedBy   = "terraform"
    Namespace   = local.namespace
    Project     = local.project
    Repo        = "github.com/caseysparkz/monorepo"
    RepoPath    = "infra/manifests/com/amazonaws/eks"
  }
}

# Data =========================================================================

# Resources ====================================================================
module "aws_resourcegroups_group" {
  source              = "../../../../modules/aws_resourcegroup_by_tagset"
  resource_group_name = "${local.namespace}-rg"
  common_tags         = local.common_tags
}

# Outputs ======================================================================
