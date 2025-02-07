###############################################################################
# GitHub
#
# Author:       Casey Sparks
# Date:         February 12, 2025
# Description:  GitHub config.

locals {
  github_repositories = {
    for repo, settings in var.github_repositories :
    repo => merge(settings, local.github_default_repository_settings)
  }
  github_default_repository_settings = {
    description                             = ""
    homepage_url                            = ""
    visibility                              = "private"
    has_issues                              = false
    has_discussions                         = false
    has_projects                            = false
    has_wiki                                = false
    is_template                             = false
    allow_merge_commit                      = false
    allow_squash_merge                      = true
    allow_rebase_merge                      = true
    allow_auto_merge                        = true
    squash_merge_commit_title               = "PR TITLE"
    squash_merge_commit_message             = "COMMIT_MESSAGES"
    merge_commit_title                      = "PR_TITLE"
    merge_commit_message                    = "PR_BODY"
    delete_branch_on_merge                  = true
    web_commit_signoff_required             = true
    has_downloads                           = false # DEPRECATED
    auto_init                               = true
    gitignore_template                      = "Python"
    license_template                        = "mit"
    default_branch                          = "main" # DEPRECATED
    archived                                = false
    archive_on_destroy                      = true
    vulnerability_alerts                    = true
    ignore_vulnerability_alerts_during_read = true
    allow_update_branch                     = true
  }
}

## Resources ==================================================================
## Organization Settings ------------------------------------------------------
resource "github_organization_settings" "caseysparkz" {
  name                                                         = "caseyspar-kz"
  company                                                      = "CaseySpar.kz"
  description                                                  = ""
  blog                                                         = "https://www.${var.root_domain}"
  email                                                        = "contact@${var.root_domain}"
  billing_email                                                = "github@${var.root_domain}"
  location                                                     = "United States of America"
  twitter_username                                             = ""
  default_repository_permission                                = "read"
  members_can_create_repositories                              = false
  members_can_create_public_repositories                       = false
  members_can_create_private_repositories                      = false
  members_can_create_internal_repositories                     = false
  members_can_fork_private_repositories                        = false
  members_can_create_pages                                     = false
  members_can_create_public_pages                              = false
  members_can_create_private_pages                             = false
  advanced_security_enabled_for_new_repositories               = true
  dependabot_alerts_enabled_for_new_repositories               = true
  dependabot_security_updates_enabled_for_new_repositories     = true
  dependency_graph_enabled_for_new_repositories                = true
  secret_scanning_enabled_for_new_repositories                 = true
  secret_scanning_push_protection_enabled_for_new_repositories = true
  web_commit_signoff_required                                  = true
  has_organization_projects                                    = false
  has_repository_projects                                      = false
}

## Repositories ---------------------------------------------------------------
resource "github_repository" "repo" {
  for_each                                = local.github_repositories
  name                                    = each.key
  description                             = each.value.description
  homepage_url                            = each.value.homepage_url
  visibility                              = each.value.visibility
  has_issues                              = each.value.has_issues
  has_discussions                         = each.value.has_discussions
  has_projects                            = each.value.has_projects
  has_wiki                                = each.value.has_wiki
  is_template                             = each.value.is_template
  allow_merge_commit                      = each.value.allow_merge_commit
  allow_squash_merge                      = each.value.allow_squash_merge
  allow_rebase_merge                      = each.value.allow_rebase_merge
  allow_auto_merge                        = each.value.allow_auto_merge
  squash_merge_commit_title               = each.value.squash_merge_commit_title
  squash_merge_commit_message             = each.value.squash_merge_commit_message
  merge_commit_title                      = each.value.merge_commit_title
  merge_commit_message                    = each.value.merge_commit_message
  delete_branch_on_merge                  = each.value.delete_branch_on_merge
  web_commit_signoff_required             = each.value.web_commit_signoff_required
  has_downloads                           = each.value.has_downloads
  auto_init                               = each.value.auto_init
  gitignore_template                      = each.value.gitignore_template
  license_template                        = each.value.license_template
  archived                                = each.value.archived
  archive_on_destroy                      = each.value.archive_on_destroy
  vulnerability_alerts                    = each.value.vulnerability_alerts
  ignore_vulnerability_alerts_during_read = each.value.ignore_vulnerability_alerts_during_read
  allow_update_branch                     = each.value.allow_update_branch
}

## Branches -------------------------------------------------------------------
resource "github_branch" "main" {
  for_each   = github_repository.repo
  repository = each.value.name
  branch     = "main"
}

resource "github_branch_default" "main" {
  for_each   = github_branch.main
  repository = each.value.repository
  branch     = each.value.branch
}

## Branch Protection Rules ----------------------------------------------------
resource "github_repository_ruleset" "default_block_force_pushes" {
  for_each    = github_branch_default.main
  name        = "[DEFAULT] Block force pushes"
  repository  = each.value.repository
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  bypass_actors {
    actor_id    = 1
    actor_type  = "OrganizationAdmin"
    bypass_mode = "always"
  }

  rules { non_fast_forward = true }
}

resource "github_repository_ruleset" "default_block_deletion" {
  for_each    = github_branch_default.main
  name        = "[DEFAULT] Block deletion"
  repository  = each.value.repository
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules { deletion = true }
}

resource "github_repository_ruleset" "default_require_pull_request" {
  for_each    = github_branch_default.main
  name        = "[DEFAULT] Require pull request"
  repository  = each.value.repository
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  bypass_actors {
    actor_id    = 1
    actor_type  = "OrganizationAdmin"
    bypass_mode = "always"
  }

  rules {
    pull_request {
      dismiss_stale_reviews_on_push = true
      require_code_owner_review     = true
      require_last_push_approval    = true
    }
  }
}

resource "github_repository_ruleset" "default_require_signatures" {
  for_each    = github_branch_default.main
  name        = "[master] Require signed commits"
  repository  = each.value.repository
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules { required_signatures = true }
}

resource "github_repository_ruleset" "default_linear_history" {
  for_each    = github_branch_default.main
  name        = "[DEFAULT] Require linear history"
  repository  = each.value.repository
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules { required_linear_history = true }
}

resource "github_repository_ruleset" "master_block_creation" {
  for_each    = github_branch_default.main
  name        = "[DEFAULT] Block deletion"
  repository  = each.value.repository
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["master"]
      exclude = []
    }
  }

  rules { creation = true }
}

resource "github_repository_ruleset" "master_block_update" {
  for_each    = github_branch_default.main
  name        = "[master] Block updates"
  repository  = each.value.repository
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["master"]
      exclude = []
    }
  }

  rules { update = false }
}
