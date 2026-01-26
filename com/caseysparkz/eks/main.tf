################################################################################
# Main
#
# Author:       Casey Sparks
# Date:         January 25, 2026
# Description:  EKS.

locals {
  aws_account_id = data.aws_caller_identity.this.account_id
  environment    = var.environment
  project        = "caseysparkz"
  application    = "eks"
  namespace      = "${local.environment}-${local.project}-${local.application}"
  common_tags = {
    ManagedBy   = "terraform"
    Application = local.application
    Domain      = var.root_domain
    Namespace   = local.namespace
  }
}

# Data -------------------------------------------------------------------------
data "aws_caller_identity" "this" {}

# Resources --------------------------------------------------------------------
resource "aws_resourcegroups_group" "this" {
  name = "${local.namespace}-rg"
  tags = { Name = "${local.namespace}-rg" }

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"]
      TagFilters          = [for key, value in local.common_tags : { Key = key, Values = [value] }]
    })
  }
}

resource "aws_eks_cluster" "this" {
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSBlockStoragePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSComputePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSLoadBalancingPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSNetworkingPolicy,
  ]
  name                          = "${local.namespace}-test"
  role_arn                      = aws_iam_role.cluster.arn
  version                       = var.eks_version
  bootstrap_self_managed_addons = false
  tags                          = { Name = "${local.namespace}-eks-cluster" }

  access_config { authentication_mode = "API" }

  compute_config {
    enabled       = true
    node_pools    = ["general-purpose"]
    node_role_arn = aws_iam_role.node.arn
  }

  encryption_config {
    resources = ["secrets"]

    provider { key_arn = "arn:aws:kms:${var.aws_region}:${local.aws_account_id}:key/${var.aws_kms_key_id}" }
  }

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    subnet_ids              = aws_subnet.this.*.id
  }

  kubernetes_network_config {
    elastic_load_balancing { enabled = true }
  }

  storage_config {
    block_storage { enabled = true }
  }
}

/*
resource "aws_eks_access_entry" "this" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = data.aws_caller_identity.this.arn
  type          = "STANDARD"
  tags          = { Name = "${local.namespace}-eks-accessentry-00" }
}
*/

# Outputs ----------------------------------------------------------------------
output "aws_cluster_endpoint" {
  description = "URL of the EKS cluster."
  value       = aws_eks_cluster.this.endpoint
  sensitive   = false
}

output "aws_cluster_ca_data" {
  description = "Certificate authority data for the cluster."
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = false
}

output "update_kubectl_cmd" {
  description = "Command to run to update your local kubectl config."
  value       = <<-EOT
    aws eks update-kubeconfig \
      --name "${aws_eks_cluster.this.name}" \
      --region "${var.aws_region}" \
      --alias "${local.environment}-eks" \
    EOT
  sensitive   = false
}
