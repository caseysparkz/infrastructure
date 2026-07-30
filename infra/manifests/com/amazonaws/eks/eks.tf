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
  enable_cluster_creator_admin_permissions = true

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
  /*
  access_entries map(object({
    kubernetes_groups = optional(list(string))
    principal_arn = string
    type = optional(string, "STANDARD")
    user_name = optional(string)
    tags = { Name = "${local.namespace}-eks-nodegroup-selfmanaged" }
    policy_associations = optional(map(object({
      policy_arn = string
      access_scope = object({
        namespaces = optional(list(string))
        type = string })
      })))
  }))
  additional_security_group_ids = list(string)
  addons = map(object({
    name = optional(string)l
    before_compute = optional(bool, false)
    most_recent = optional(bool, true)
    addon_version = optional(string)
    configuration_values = optional(string)
    namespace_config = optional(object({ namespace = string }))
    pod_identity_association = optional(list(object({ role_arn = string service_account = string }))) preserve = optional(bool, true) resolve_conflicts_on_create = optional(string, "NONE") resolve_conflicts_on_update = optional(string, "OVERWRITE") service_account_role_arn = optional(string) timeouts = optional(object({ create = optional(string) update = optional(string) delete = optional(string) }), {}) tags = optional(map(string), {})
  }))
  addons_timeouts = object({ create = optional(string) update = optional(string) delete = optional(string) })
  attach_encryption_policy = true
  authentication_mode = "API_AND_CONFIG_MAP"
  cloudwatch_log_group_class = "INFREQUENT_ACCESS"
  cloudwatch_log_group_kms_key_id = "" // TODO
  cloudwatch_log_group_retention_in_days = 90
  cloudwatch_log_group_tags = { Namespace = local.namespace }
  cluster_tags = { Name = "${local.namespace}-eks-cluster" }
  compute_config = object({
    enabled = optional(bool, false)
    node_pools = optional(list(string))
    node_role_arn = optional(string)
  })
  control_plane_egress_mode = "AWS_MANAGED"
  control_plane_scaling_config = { tier = "standard }
  control_plane_subnet_ids = module.vpc.private_subnets
  create = true
  create_auto_mode_iam_resources = false
  create_cloudwatch_log_group = true
  create_cni_ipv6_iam_policy = false
  create_iam_role = true
  create_kms_key = true
  create_node_iam_role = true
  create_node_security_group = true
  create_primary_security_group_tags = true
  create_security_group = true
  custom_oidc_thumbprints = []
  dataplane_wait_duration = "30s"
  deletion_protection = false
  eks_managed_node_groups = map(object({
    create = optional(bool)
    kubernetes_version = optional(string)l
    name = "${local.namespace}-eks-nodegroup-managed"
    use_name_prefix = optional(bool)
    subnet_ids = module.vpc.private_subnets
    min_size = 1
    max_size = 1
    desired_size = 1
    ami_id = optional(string)
    ami_type = optional(string)
    ami_release_version = optional(string)
    use_latest_ami_release_version = true
    capacity_type = optional(string)
    disk_size = optional(number)
    force_update_version = true
    instance_types = optional(list(string))
    labels = optional(map(string))
    node_repair_config = optional(object({
      enabled = optional(bool)
      max_parallel_nodes_repaired_count = optional(number)
      max_parallel_nodes_repaired_percentage = optional(number)
      max_unhealthy_node_threshold_count = optional(number)
      max_unhealthy_node_threshold_percentage = optional(number)
      node_repair_config_overrides = optional(list(object({
        min_repair_wait_time_mins = number
        node_monitoring_condition = string
        node_unhealthy_reason = string
        repair_action = string
      })))
    }))
    remote_access = optional(object({
      ec2_ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDHPL8yK7QMnLa79MNY6vgUX4VIZGVSLYbjsi2bEZZE+"
      source_security_group_ids = optional(list(string))
    }))
    taints = optional(map(object({ key = string value = optional(string) effect = string })))
    update_config = optional(object({ max_unavailable = optional(number) max_unavailable_percentage = optional(number) update_strategy = optional(string) }))
    timeouts = optional(object({ create = optional(string) update = optional(string) delete = optional(string) }))
    enable_bootstrap_user_data = optional(bool)
    pre_bootstrap_user_data = optional(string)
    post_bootstrap_user_data = optional(string)
    bootstrap_extra_args = optional(string)
    user_data_template_path = optional(string)
    cloudinit_pre_nodeadm = optional(list(object({ content = string content_type = optional(string) filename = optional(string) merge_type = optional(string) })))
    cloudinit_post_nodeadm = optional(list(object({ content = string content_type = optional(string) filename = optional(string) merge_type = optional(string) })))
    create_launch_template = optional(bool)
    use_custom_launch_template = optional(bool)
    launch_template_id = optional(string)
    launch_template_name = optional(string)
    launch_template_use_name_prefix = optional(bool)
    launch_template_version = optional(string)
    launch_template_default_version = optional(string)
    update_launch_template_default_version = optional(bool)
    launch_template_description = optional(string)
    launch_template_tags = optional(map(string))
    tag_specifications = optional(list(string))
    ebs_optimized = optional(bool)
    key_name = optional(string)
    disable_api_termination = optional(bool)
    kernel_id = optional(string)
    ram_disk_id = optional(string)
    block_device_mappings = optional(map(object({
      device_name = optional(string)
      ebs = optional(object({
        delete_on_termination = optional(bool)
        encrypted = optional(bool)
        iops = optional(number)
        kms_key_id = optional(string)
        snapshot_id = optional(string)
        throughput = optional(number)
        volume_initialization_rate = optional(number)
        volume_size = optional(number)
        volume_type = optional(string)
      }))
      no_device = optional(string)
      virtual_name = optional(string)
    })))
    capacity_reservation_specification = optional(object({
      capacity_reservation_preference = optional(string)
      capacity_reservation_target = optional(object({
        capacity_reservation_id = optional(string)
        capacity_reservation_resource_group_arn = optional(string)
      }))
    }))
    cpu_options = optional(object({
      amd_sev_snp = optional(string)
      core_count = optional(number)
      nested_virtualization = optional(string)
      threads_per_core = optional(number)
    }))
    credit_specification = optional(object({ cpu_credits = optional(string) }))
    enclave_options = optional(object({ enabled = optional(bool) }))
    instance_market_options = optional(object({
      market_type = optional(string)
      spot_options = optional(object({
        block_duration_minutes = optional(number)
        instance_interruption_behavior = optional(string)
        max_price = optional(string)
        spot_instance_type = optional(string)
        valid_until = optional(string)
      }))
    }))
    license_specifications = optional(list(object({ license_configuration_arn = string })))
    metadata_options = optional(object({
      http_endpoint = optional(string)
      http_protocol_ipv6 = optional(string)
      http_put_response_hop_limit = optional(number)
      http_tokens = optional(string)
      instance_metadata_tags = optional(string)
    }))
    enable_monitoring = optional(bool)
    enable_efa_support = optional(bool)
    enable_efa_only = optional(bool)
    efa_indices = optional(list(string))
    create_placement_group = optional(bool)
    placement = optional(object({
      affinity = optional(string)
      availability_zone = optional(string)
      group_name = optional(string)
      host_id = optional(string)
      host_resource_group_arn = optional(string)
      partition_number = optional(number)
      spread_domain = optional(string)
      tenancy = optional(string)
    }))
    network_interfaces = optional(list(object({
      associate_carrier_ip_address = optional(bool)
      associate_public_ip_address = optional(bool)
      connection_tracking_specification = optional(object({
        tcp_established_timeout = optional(number)
        udp_stream_timeout = optional(number)
        udp_timeout = optional(number)
      }))
      delete_on_termination = optional(bool)
      description = optional(string)
      device_index = optional(number)
      ena_srd_specification = optional(object({
        ena_srd_enabled = optional(bool)
        ena_srd_udp_specification = optional(object({ ena_srd_udp_enabled = optional(bool) }))
      }))
      interface_type = optional(string)
      ipv4_address_count = optional(number)
      ipv4_addresses = optional(list(string))
      ipv4_prefix_count = optional(number)
      ipv4_prefixes = optional(list(string))
      ipv6_address_count = optional(number)
      ipv6_addresses = optional(list(string))
      ipv6_prefix_count = optional(number)
      ipv6_prefixes = optional(list(string))
      network_card_index = optional(number)
      network_interface_id = optional(string)
      primary_ipv6 = optional(bool)
      private_ip_address = optional(string)
      security_groups = optional(list(string), [])
      subnet_id = optional(string)
    })))
    network_performance_options = optional(object({ bandwidth_weighting = optional(string) }))
    maintenance_options = optional(object({ auto_recovery = optional(string) }))
    private_dns_name_options = optional(object({
      enable_resource_name_dns_aaaa_record = optional(bool)
      enable_resource_name_dns_a_record = optional(bool)
      hostname_type = optional(string)
    }))
    iam_role_arn = optional(string)
    iam_role_name = optional(string)
    iam_role_use_name_prefix = optional(bool)
    iam_role_path = optional(string)
    iam_role_description = optional(string)
    iam_role_permissions_boundary = optional(string)
    iam_role_tags = optional(map(string))
    iam_role_attach_cni_policy = optional(bool)
    iam_role_additional_policies = optional(map(string))
    create_iam_role_policy = optional(bool)
    iam_role_policy_statements = optional(list(object({
      sid = optional(string)
      actions = optional(list(string))
      not_actions = optional(list(string))
      effect = optional(string)
      resources = optional(list(string))
      not_resources = optional(list(string))
      principals = optional(list(object({
        type = string
        identifiers = list(string)
      })))
      not_principals = optional(list(object({
        type = string
        identifiers = list(string)
      })))
      condition = optional(list(object({
        test = string
        values = list(string)
        variable = string
      })))
    })))
    vpc_security_group_ids = optional(list(string), [])
    attach_cluster_primary_security_group = optional(bool, false)
    cluster_primary_security_group_id = optional(string)
    create_security_group = optional(bool)
    security_group_name = optional(string)
    security_group_use_name_prefix = optional(bool)
    security_group_description = optional(string)
    security_group_ingress_rules = optional(map(object({
      name = optional(string)
      cidr_ipv4 = optional(string)
      cidr_ipv6 = optional(string)
      description = optional(string)
      from_port = optional(string)
      ip_protocol = optional(string)
      prefix_list_id = optional(string)
      referenced_security_group_id = optional(string)
      self = optional(bool)
      tags = optional(map(string))
      to_port = optional(string)
    })))
    security_group_egress_rules = optional(map(object({
      name = optional(string)
      cidr_ipv4 = optional(string)
      cidr_ipv6 = optional(string)
      description = optional(string)
      from_port = optional(string)
      ip_protocol = optional(string)
      prefix_list_id = optional(string)
      referenced_security_group_id = optional(string)
      self = optional(bool)
      tags = optional(map(string))
      to_port = optional(string)
    })))
    security_group_tags = { Name = "${local.namespace}-sg-eksmanagednodegroup" }
    tags = optional(map(string))
  }))
  enable_auto_mode_custom_tags = true
  enable_cluster_creator_admin_permissions = true
  enable_irsa = true
  enable_kms_key_rotation = true
  enabled_log_types = ["audit"]
  encryption_config = object({ provider_key_arn = optional(string) resources = optional(list(string), ["secrets"]) })
  encryption_policy_description = "Cluster encryption policy to allow cluster role to utilize CMK provided"
  encryption_policy_name = "${local.namespace}-iam-policy-eksencryption"
  encryption_policy_path = "/eks/"
  encryption_policy_tags = { Name = "${local.namespace}-iam-policy-eksencryption" }
  encryption_policy_use_name_prefix = false
  endpoint_private_access = true
  endpoint_public_access = true
  endpoint_public_access_cidrs = ["0.0.0.0/0"] // TODO
  fargate_profiles = map(object({
    create = optional(bool)
    name = optional(string)
    subnet_ids = optional(list(string))
    selectors = optional(list(object({
      labels = optional(map(string))
      namespace = string
    })))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
    }))
    create_iam_role = true
    iam_role_arn = optional(string)
    iam_role_name = optional(string)
    iam_role_use_name_prefix = optional(bool)
    iam_role_path = optional(string)
    iam_role_description = optional(string)
    iam_role_permissions_boundary = optional(string)
    iam_role_tags = optional(map(string))
    iam_role_attach_cni_policy = optional(bool)
    iam_role_additional_policies = optional(map(string))
    create_iam_role_policy = optional(bool)
    iam_role_policy_statements = optional(list(object({
      sid = optional(string)
      actions = optional(list(string))
      not_actions = optional(list(string))
      effect = optional(string)
      resources = optional(list(string))
      not_resources = optional(list(string))
      principals = optional(list(object({
        type = string
        identifiers = list(string)
      })))
      not_principals = optional(list(object({
        type = string
        identifiers = list(string)
      })))
      condition = optional(list(object({
        test = string
        values = list(string)
        variable = string
      })))
    })))
    tags = optional(map(string))
  }))
  force_update_version = false
  iam_role_additional_policies = map(string)
  iam_role_arn = string
  iam_role_description = string
  iam_role_name = string
  iam_role_path = "/k8s/"
  iam_role_permissions_boundary = string
  iam_role_tags
  map(string)
      Description: A map of additional tags to add to the IAM role created
      Default:
      {}
  iam_role_use_name_prefix
  bool
      Description: Determines whether the IAM role name (`iam_role_name`) is used as a prefix
      Default:
      true
  identity_providers
  map(object({ client_id = string groups_claim = optional(string) groups_prefix = optional(string) identity_provider_config_name = optional(string) # will fall back to map key issuer_url = string required_claims = optional(map(string)) username_claim = optional(string) username_prefix = optional(string) tags = optional(map(string), {}) }))
      Description: Map of cluster identity provider configurations to enable for the cluster. Note - this is different/separate from IRSA
      Default:
      null
  include_oidc_root_ca_thumbprint
  bool
      Description: Determines whether to include the root CA thumbprint in the OpenID Connect (OIDC) identity provider's server certificate(s)
      Default:
      true
  ip_family
  string
      Description: The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`. You can only specify an IP family when you create a cluster, changing this value will force a new cluster to be created
      Default:
      "ipv4"
  kms_key_administrators
  list(string)
      Description: A list of IAM ARNs for [key administrators](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-administrators). If no value is provided, the current caller identity is used to ensure at least one key admin is available
      Default:
      []
  kms_key_aliases
  list(string)
      Description: A list of aliases to create. Note - due to the use of `toset()`, values must be static strings and not computed values
      Default:
      []
  kms_key_deletion_window_in_days
  number
      Description: The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key. If you specify a value, it must be between `7` and `30`, inclusive. If you do not specify a value, it defaults to `30`
      Default:
      null
  kms_key_description
  string
      Description: The description of the key as viewed in AWS console
      Default:
      null
  kms_key_enable_default_policy
  bool
      Description: Specifies whether to enable the default key policy
      Default:
      true
  kms_key_override_policy_documents
  list(string)
      Description: List of IAM policy documents that are merged together into the exported document. In merging, statements with non-blank `sid`s will override statements with the same `sid`
      Default:
      []
  kms_key_owners
  list(string)
      Description: A list of IAM ARNs for those who will have full key permissions (`kms:*`)
      Default:
      []
  kms_key_rotation_period_in_days
  number
      Description: Custom period of time between each key rotation date. If you specify a value, it must be between `90` and `2560`, inclusive. If you do not specify a value, it defaults to `365`
      Default:
      null
  kms_key_service_users
  list(string)
      Description: A list of IAM ARNs for [key service users](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-service-integration)
      Default:
      []
  kms_key_source_policy_documents
  list(string)
      Description: List of IAM policy documents that are merged together into the exported document. Statements must have unique `sid`s
      Default:
      []
  kms_key_users
  list(string)
      Description: A list of IAM ARNs for [key users](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-users)
      Default:
      []
  kubernetes_version
  string
      Description: Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.33`)
      Default:
      null
  name
  string
      Description: Name of the EKS cluster
      Default:
      ""
  node_iam_role_additional_policies
  map(string)
      Description: Additional policies to be added to the EKS Auto node IAM role
      Default:
      {}
  node_iam_role_description
  string
      Description: Description of the EKS Auto node IAM role
      Default:
      null
  node_iam_role_name
  string
      Description: Name to use on the EKS Auto node IAM role created
      Default:
      null
  node_iam_role_path
  string
      Description: The EKS Auto node IAM role path
      Default:
      null
  node_iam_role_permissions_boundary
  string
      Description: ARN of the policy that is used to set the permissions boundary for the EKS Auto node IAM role
      Default:
      null
  node_iam_role_tags
  map(string)
      Description: A map of additional tags to add to the EKS Auto node IAM role created
      Default:
      {}
  node_iam_role_use_name_prefix
  bool
      Description: Determines whether the EKS Auto node IAM role name (`node_iam_role_name`) is used as a prefix
      Default:
      true
  node_security_group_additional_rules
  map(object({ protocol = optional(string, "tcp") from_port = number to_port = number type = optional(string, "ingress") description = optional(string) cidr_blocks = optional(list(string)) ipv6_cidr_blocks = optional(list(string)) prefix_list_ids = optional(list(string)) self = optional(bool) source_cluster_security_group = optional(bool, false) source_security_group_id = optional(string) }))
      Description: List of additional security group rules to add to the node security group created. Set `source_cluster_security_group = true` inside rules to set the `cluster_security_group` as source
      Default:
      {}
  node_security_group_description
  string
      Description: Description of the node security group created
      Default:
      "EKS node shared security group"
  node_security_group_enable_recommended_rules
  bool
      Description: Determines whether to enable recommended security group rules for the node security group created. This includes node-to-node TCP ingress on ephemeral ports and allows all egress traffic
      Default:
      true
  node_security_group_id
  string
      Description: ID of an existing security group to attach to the node groups created
      Default:
      ""
  node_security_group_name
  string
      Description: Name to use on node security group created
      Default:
      null
  node_security_group_tags
  map(string)
      Description: A map of additional tags to add to the node security group created
      Default:
      {}
  node_security_group_use_name_prefix
  bool
      Description: Determines whether node security group name (`node_security_group_name`) is used as a prefix
      Default:
      true
  openid_connect_audiences
  list(string)
      Description: List of OpenID Connect audience client IDs to add to the IRSA provider
      Default:
      []
  outpost_config
  object({ control_plane_instance_type = optional(string) control_plane_placement = optional(object({ group_name = string })) outpost_arns = list(string) })
      Description: Configuration for the AWS Outpost to provision the cluster on
      Default:
      null
  prefix_separator
  string
      Description: The separator to use between the prefix and the generated timestamp for resource names
      Default:
      "-"
  putin_khuylo
  bool
      Description: Do you agree that Putin doesn't respect Ukrainian sovereignty and territorial integrity? More info: https://en.wikipedia.org/wiki/Putin_khuylo!
      Default:
      true
  region
  string
      Description: Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration
      Default:
      null
  remote_network_config
  object({ remote_node_networks = object({ cidrs = optional(list(string)) }) remote_pod_networks = optional(object({ cidrs = optional(list(string)) })) })
      Description: Configuration block for the cluster remote network configuration
      Default:
      null
  security_group_additional_rules
  map(object({ protocol = optional(string, "tcp") from_port = number to_port = number type = optional(string, "ingress") description = optional(string) cidr_blocks = optional(list(string)) ipv6_cidr_blocks = optional(list(string)) prefix_list_ids = optional(list(string)) self = optional(bool) source_node_security_group = optional(bool, false) source_security_group_id = optional(string) }))
      Description: List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source
      Default:
      {}
  security_group_description
  string
      Description: Description of the cluster security group created
      Default:
      "EKS cluster security group"
  security_group_id
  string
      Description: Existing security group ID to be attached to the cluster
      Default:
      ""
  security_group_name
  string
      Description: Name to use on cluster security group created
      Default:
      null
  security_group_tags
  map(string)
      Description: A map of additional tags to add to the cluster security group created
      Default:
      {}
  security_group_use_name_prefix
  bool
      Description: Determines whether cluster security group name (`cluster_security_group_name`) is used as a prefix
      Default:
      true
  self_managed_node_groups = {
    create = optional(bool)
    kubernetes_version = optional(string) # Autoscaling Group
    create_autoscaling_group = false
    name = "${local.namespace}-eks-nodegroup-selfmanaged"
    use_name_prefix = false
    availability_zones = optional(list(string))
    subnet_ids = module.vpc.private_subnets
    min_size = 1
    max_size = 1
    desired_size = 1
    desired_size_type = optional(string)
    capacity_rebalance = optional(bool)
    default_instance_warmup = optional(number)
    protect_from_scale_in = optional(bool)
    context = optional(string)
    create_placement_group = optional(bool)
    placement_group = optional(string)
    health_check_type = optional(string)
    health_check_grace_period = optional(number)
    ignore_failed_scaling_activities = optional(bool)
    force_delete = optional(bool)
    termination_policies = optional(list(string))
    suspended_processes = optional(list(string))
    max_instance_lifetime = optional(number)
    enabled_metrics = optional(list(string))
    metrics_granularity = optional(string)
    initial_lifecycle_hooks = optional(list(object({ default_result = optional(string) heartbeat_timeout = optional(number) lifecycle_transition = string name = string notification_metadata = optional(string) notification_target_arn = optional(string) role_arn = optional(string) }))) instance_maintenance_policy = optional(object({ max_healthy_percentage = number min_healthy_percentage = number })) instance_refresh = optional(object({ preferences = optional(object({ alarm_specification = optional(object({ alarms = optional(list(string)) })) auto_rollback = optional(bool) checkpoint_delay = optional(number) checkpoint_percentages = optional(list(number)) instance_warmup = optional(number) max_healthy_percentage = optional(number) min_healthy_percentage = optional(number) scale_in_protected_instances = optional(string) skip_matching = optional(bool) standby_instances = optional(string) })) strategy = optional(string) triggers = optional(list(string)) }) ) use_mixed_instances_policy = optional(bool) mixed_instances_policy = optional(object({ instances_distribution = optional(object({ on_demand_allocation_strategy = optional(string) on_demand_base_capacity = optional(number) on_demand_percentage_above_base_capacity = optional(number) spot_allocation_strategy = optional(string) spot_instance_pools = optional(number) spot_max_price = optional(string) })) launch_template = object({ override = optional(list(object({ instance_requirements = optional(object({ accelerator_count = optional(object({ max = optional(number) min = optional(number) })) accelerator_manufacturers = optional(list(string)) accelerator_names = optional(list(string)) accelerator_total_memory_mib = optional(object({ max = optional(number) min = optional(number) })) accelerator_types = optional(list(string)) allowed_instance_types = optional(list(string)) bare_metal = optional(string) baseline_ebs_bandwidth_mbps = optional(object({ max = optional(number) min = optional(number) })) burstable_performance = optional(string) cpu_manufacturers = optional(list(string)) excluded_instance_types = optional(list(string)) instance_generations = optional(list(string)) local_storage = optional(string) local_storage_types = optional(list(string)) max_spot_price_as_percentage_of_optimal_on_demand_price = optional(number) memory_gib_per_vcpu = optional(object({ max = optional(number) min = optional(number) })) memory_mib = optional(object({ max = optional(number) min = optional(number) })) network_bandwidth_gbps = optional(object({ max = optional(number) min = optional(number) })) network_interface_count = optional(object({ max = optional(number) min = optional(number) })) on_demand_max_price_percentage_over_lowest_price = optional(number) require_hibernate_support = optional(bool) spot_max_price_percentage_over_lowest_price = optional(number) total_local_storage_gb = optional(object({ max = optional(number) min = optional(number) })) vcpu_count = optional(object({ max = optional(number) min = optional(number) })) })) instance_type = optional(string) launch_template_specification = optional(object({ launch_template_id = optional(string) launch_template_name = optional(string) version = optional(string) })) weighted_capacity = optional(string) }))) }) })) timeouts = optional(object({ delete = optional(string) })) autoscaling_group_tags = optional(map(string)) # User data ami_type = optional(string) additional_cluster_dns_ips = optional(list(string)) pre_bootstrap_user_data = optional(string) post_bootstrap_user_data = optional(string) bootstrap_extra_args = optional(string) user_data_template_path = optional(string) cloudinit_pre_nodeadm = optional(list(object({ content = string content_type = optional(string) filename = optional(string) merge_type = optional(string) }))) cloudinit_post_nodeadm = optional(list(object({ content = string content_type = optional(string) filename = optional(string) merge_type = optional(string) }))) # Launch Template create_launch_template = optional(bool) use_custom_launch_template = optional(bool) launch_template_id = optional(string) launch_template_name = optional(string) # Will fall back to map key launch_template_use_name_prefix = optional(bool) launch_template_version = optional(string) launch_template_default_version = optional(string) update_launch_template_default_version = optional(bool) launch_template_description = optional(string) launch_template_tags = optional(map(string)) tag_specifications = optional(list(string)) ebs_optimized = optional(bool) ami_id = optional(string) instance_type = optional(string) key_name = optional(string) disable_api_termination = optional(bool) instance_initiated_shutdown_behavior = optional(string) kernel_id = optional(string) ram_disk_id = optional(string) block_device_mappings = optional(map(object({ device_name = optional(string) ebs = optional(object({ delete_on_termination = optional(bool) encrypted = optional(bool) iops = optional(number) kms_key_id = optional(string) snapshot_id = optional(string) throughput = optional(number) volume_initialization_rate = optional(number) volume_size = optional(number) volume_type = optional(string) })) no_device = optional(string) virtual_name = optional(string) }))) capacity_reservation_specification = optional(object({ capacity_reservation_preference = optional(string) capacity_reservation_target = optional(object({ capacity_reservation_id = optional(string) capacity_reservation_resource_group_arn = optional(string) })) })) cpu_options = optional(object({ amd_sev_snp = optional(string) core_count = optional(number) nested_virtualization = optional(string) threads_per_core = optional(number) })) credit_specification = optional(object({ cpu_credits = optional(string) })) enclave_options = optional(object({ enabled = optional(bool) })) instance_requirements = optional(object({ accelerator_count = optional(object({ max = optional(number) min = optional(number) })) accelerator_manufacturers = optional(list(string)) accelerator_names = optional(list(string)) accelerator_total_memory_mib = optional(object({ max = optional(number) min = optional(number) })) accelerator_types = optional(list(string)) allowed_instance_types = optional(list(string)) bare_metal = optional(string) baseline_ebs_bandwidth_mbps = optional(object({ max = optional(number) min = optional(number) })) burstable_performance = optional(string) cpu_manufacturers = optional(list(string)) excluded_instance_types = optional(list(string)) instance_generations = optional(list(string)) local_storage = optional(string) local_storage_types = optional(list(string)) max_spot_price_as_percentage_of_optimal_on_demand_price = optional(number) memory_gib_per_vcpu = optional(object({ max = optional(number) min = optional(number) })) memory_mib = optional(object({ max = optional(number) min = optional(number) })) network_bandwidth_gbps = optional(object({ max = optional(number) min = optional(number) })) network_interface_count = optional(object({ max = optional(number) min = optional(number) })) on_demand_max_price_percentage_over_lowest_price = optional(number) require_hibernate_support = optional(bool) spot_max_price_percentage_over_lowest_price = optional(number) total_local_storage_gb = optional(object({ max = optional(number) min = optional(number) })) vcpu_count = optional(object({ max = optional(number) min = string })) })) instance_market_options = optional(object({ market_type = optional(string) spot_options = optional(object({ block_duration_minutes = optional(number) instance_interruption_behavior = optional(string) max_price = optional(string) spot_instance_type = optional(string) valid_until = optional(string) })) })) license_specifications = optional(list(object({ license_configuration_arn = string }))) metadata_options = optional(object({ http_endpoint = optional(string) http_protocol_ipv6 = optional(string) http_put_response_hop_limit = optional(number) http_tokens = optional(string) instance_metadata_tags = optional(string) })) enable_monitoring = optional(bool) enable_efa_support = optional(bool) enable_efa_only = optional(bool) efa_indices = optional(list(string)) network_interfaces = optional(list(object({ associate_carrier_ip_address = optional(bool) associate_public_ip_address = optional(bool) connection_tracking_specification = optional(object({ tcp_established_timeout = optional(number) udp_stream_timeout = optional(number) udp_timeout = optional(number) })) delete_on_termination = optional(bool) description = optional(string) device_index = optional(number) ena_srd_specification = optional(object({ ena_srd_enabled = optional(bool) ena_srd_udp_specification = optional(object({ ena_srd_udp_enabled = optional(bool) })) })) interface_type = optional(string) ipv4_address_count = optional(number) ipv4_addresses = optional(list(string)) ipv4_prefix_count = optional(number) ipv4_prefixes = optional(list(string)) ipv6_address_count = optional(number) ipv6_addresses = optional(list(string)) ipv6_prefix_count = optional(number) ipv6_prefixes = optional(list(string)) network_card_index = optional(number) network_interface_id = optional(string) primary_ipv6 = optional(bool) private_ip_address = optional(string) security_groups = optional(list(string)) subnet_id = optional(string) }))) network_performance_options = optional(object({ bandwidth_weighting = optional(string) })) placement = optional(object({ affinity = optional(string) availability_zone = optional(string) group_name = optional(string) host_id = optional(string) host_resource_group_arn = optional(string) partition_number = optional(number) spread_domain = optional(string) tenancy = optional(string) })) maintenance_options = optional(object({ auto_recovery = optional(string) })) private_dns_name_options = optional(object({ enable_resource_name_dns_aaaa_record = optional(bool) enable_resource_name_dns_a_record = optional(bool) hostname_type = optional(string) })) # IAM role create_iam_instance_profile = optional(bool) iam_instance_profile_arn = optional(string) iam_role_name = optional(string) iam_role_use_name_prefix = optional(bool) iam_role_path = optional(string) iam_role_description = optional(string) iam_role_permissions_boundary = optional(string) iam_role_tags = optional(map(string)) iam_role_attach_cni_policy = optional(bool) iam_role_additional_policies = optional(map(string)) create_iam_role_policy = optional(bool) iam_role_policy_statements = optional(list(object({ sid = optional(string) actions = optional(list(string)) not_actions = optional(list(string)) effect = optional(string) resources = optional(list(string)) not_resources = optional(list(string)) principals = optional(list(object({ type = string identifiers = list(string) }))) not_principals = optional(list(object({ type = string identifiers = list(string) }))) condition = optional(list(object({ test = string values = list(string) variable = string }))) }))) # Access entry create_access_entry = optional(bool) iam_role_arn = optional(string) # Security group vpc_security_group_ids = optional(list(string), []) attach_cluster_primary_security_group = optional(bool, false) create_security_group = optional(bool) security_group_name = optional(string) security_group_use_name_prefix = optional(bool) security_group_description = optional(string) security_group_ingress_rules = optional(map(object({ name = optional(string) cidr_ipv4 = optional(string) cidr_ipv6 = optional(string) description = optional(string) from_port = optional(string) ip_protocol = optional(string) prefix_list_id = optional(string) referenced_security_group_id = optional(string) self = optional(bool) tags = optional(map(string)) to_port = optional(string) }))) security_group_egress_rules = optional(map(object({ name = optional(string) cidr_ipv4 = optional(string) cidr_ipv6 = optional(string) description = optional(string) from_port = optional(string) ip_protocol = optional(string) prefix_list_id = optional(string) referenced_security_group_id = optional(string) self = optional(bool) tags = optional(map(string)) to_port = optional(string) }))) security_group_tags = optional(map(string)) tags = optional(map(string)) }))
      Description: Map of self-managed node group definitions to create
      Default:
      null
  service_ipv4_cidr = "" //TODO
  subnet_ids = list(string) // TODO
  tags = { Name = "${local.namespace}-eks-cluster" }
  upgrade_policy = { support_type = "STANDARD" }
  vpc_id = module.vpc.vpc_arn
*/
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
