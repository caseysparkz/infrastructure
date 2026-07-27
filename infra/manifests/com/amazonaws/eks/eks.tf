################################################################################
# EKS
#

# Data =========================================================================

# Modules ======================================================================
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.24"
  tags    = { Name = "${local.namespace}-eks-cluster" }

  // K8S config
  name               = "${local.namespace}-eks-cluster"
  kubernetes_version = "1.36"

  // Network config
  endpoint_private_access             = true
  endpoint_public_access              = false
  endpoint_public_access_cidrs        = []
  vpc_id                              = module.vpc.vpc_id
  subnet_ids                          = module.vpc.private_subnets
  ip_family                           = "ipv4"
  security_group_name                 = "${local.namespace}-sg"
  security_group_tags                 = { Name = "${local.namespace}-sg" }
  security_group_use_name_prefix      = true
  create_node_security_group          = true
  node_security_group_name            = "${local.namespace}-sg-node"
  node_security_group_tags            = { Name = "${local.namespace}-sg-node" }
  node_security_group_use_name_prefix = true

  // Cloudwatch config
  // TODO

  // Encryption config
  create_kms_key                    = true
  enable_kms_key_rotation           = true
  encryption_policy_name            = "${local.namespace}-iam-policy-clusterencryption"
  encryption_policy_tags            = { Name = "${local.namespace}-iam-policy-clusterencryption" }
  encryption_policy_use_name_prefix = true
  kms_key_aliases                   = ["${local.namespace}-kms-key"]
  kms_key_deletion_window_in_days   = 7
  kms_key_description               = "${local.namespace}-eks-cluster KMS key."
  kms_key_enable_default_policy     = true
  kms_key_rotation_period_in_days   = 90

  // IAM config
  iam_role_name                            = "${local.namespace}-iam-role"
  iam_role_tags                            = { Name = "${local.namespace}-iam-role" }
  enable_cluster_creator_admin_permissions = true
  create_node_iam_role                     = true

  // Node config
  eks_managed_node_groups = {
    general = {
      min_size       = 1
      max_size       = 1
      desired_size   = 1
      instance_types = ["t2.micro"]
      capacity_type  = "ON_DEMAND"
      ec2_ssh_key    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDHPL8yK7QMnLa79MNY6vgUX4VIZGVSLYbjsi2bEZZE+"
    }
  }
}

# Outputs ======================================================================
output "cluster_name" {
  description = "Name of the provisioned EKS cluster."
  value       = module.eks.cluster_name
  sensitive   = false
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}
