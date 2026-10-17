/* Main */

locals {
  environment = "global"
  project     = "terraform"
  application = "state"
  namespace   = "${local.environment}-${local.project}-${local.application}"
  owner       = "tfstate@caseysparkz.com"
  common_tags = {
    Application = local.application
    Environment = local.environment
    Project     = local.project
    Namespace   = local.namespace
    ManagedBy   = "terraform"
    Namespace   = local.namespace
    Owner       = local.owner
    Repo        = "github.com/caseysparkz/monorepo"
    RepoPath    = "infra/manifests/tfstate"
  }
  state_principal_arns = distinct(concat(var.reader_principal_arns, var.writer_principal_arns))
}

// Data ========================================================================
data "aws_caller_identity" "this" {}

data "aws_region" "this" {}

// Resources ===================================================================
resource "aws_resourcegroups_group" "this" {
  name = "${local.namespace}-rg"
  tags = { Name = "${local.namespace}-rg" }

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"]
      TagFilters = [
        for key, value in local.common_tags :
        {
          Key    = key
          Values = [value]
        }
      ]
    })
  }
}
