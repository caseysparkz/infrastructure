################################################################################
# Main
#
# Author:       Casey Sparks
# Date:         July 28, 2026
# Description:  Minimal security policies and org-wide security implementations
#               for my AWS organization.

locals {
  environment = "all"
  project     = "aws"
  application = "config"
  namespace   = "${local.environment}-${local.project}-${local.application}"
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

# Modules ======================================================================

# Resources ====================================================================
resource "aws_ebs_encryption_by_default" "this" {
  enabled = true // Require EBS encryption
}

resource "aws_ec2_instance_metadata_defaults" "this" {
  http_tokens = "required" // Require IMDSv2
}

# Outputs ======================================================================
