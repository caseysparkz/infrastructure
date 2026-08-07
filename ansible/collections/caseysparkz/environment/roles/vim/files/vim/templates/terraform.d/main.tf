/*
Main

Author:       Casey Sparks
Date:         DATE
Description:  x
*/

locals {
  environment = "" // TODO
  project     = "" // TODO
  application = "" // TODO
  namespace   = "${local.environment}-${local.project}-${local.application}"
  common_tags = {
    Application = local.application
    Environment = local.environment
    ManagedBy   = "terraform"
    Project     = local.project
    Repo        = "github.com/caseysparkz/monorepo"
    RepoPath    = "infra/manifests/<CHANGEME>" // TODO
  }
}

// Data ========================================================================

// Modules =====================================================================
/*
module "aws_resourcegroups_group" {
  source              = "<CHANGME>/../modules/aws_resourcegroup_by_tagset" // TODO
  resource_group_name = "${local.namespace}-rg"
  common_tags         = local.common_tags
}
*/

// Resources ===================================================================

// Outputs =====================================================================
