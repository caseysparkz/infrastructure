/* Monitoring: CloudTrail -> CloudWatch Logs -> Alarms -> SNS */

locals {
  monitoring_log_group_name = "/aws/cloudtrail/${local.cloudtrail_name}"
  monitoring_log_group_arn  = "arn:aws:logs:${data.aws_region.this.region}:${data.aws_caller_identity.this.account_id}:log-group:${local.monitoring_log_group_name}"
  monitoring_topic_name     = "${local.namespace}-sns-topic-alerts"
  monitoring_topic_arn      = "arn:aws:sns:${data.aws_region.this.region}:${data.aws_caller_identity.this.account_id}:${local.monitoring_topic_name}"
  monitoring_alarm_prefix   = "${local.namespace}-alarm-"
  monitoring_alarm_arn_glob = "arn:aws:cloudwatch:${data.aws_region.this.region}:${data.aws_caller_identity.this.account_id}:alarm:${local.monitoring_alarm_prefix}*"
  monitoring_rule_name      = "${local.namespace}-events-rule-tamper"
  monitoring_rule_arn       = "arn:aws:events:${data.aws_region.this.region}:${data.aws_caller_identity.this.account_id}:rule/${local.monitoring_rule_name}"
  monitoring_kms_alias      = "alias/${local.namespace}-kms-key-monitoring"
  monitoring_kms_crypto_ops = ["Decrypt", "Encrypt", "GenerateDataKey", "GenerateDataKeyWithoutPlaintext", "ReEncrypt"]
  monitoring_readonly_role_names = toset([ // Non-admin state principals (roles only; SSO-reserved roles are immutable)
    for arn in setsubtract(local.state_principal_arns, var.admin_principal_arns) :
    element(split("/", arn), length(split("/", arn)) - 1)
    if can(regex(":role/", arn)) && !can(regex(":role/aws-reserved/", arn))
  ])
  monitoring_alarms = { // CloudWatch Logs metric filter patterns, matched against CloudTrail records.
    state-read = {
      description = "Terraform state object read."
      pattern     = <<-EOT
        {
          ($.eventSource = "s3.amazonaws.com")
          && ($.requestParameters.bucketName = "${aws_s3_bucket.this.id}")
          && ($.eventName = "GetObject")
          && ($.requestParameters.key != "*.tflock")
          && ($.errorCode NOT EXISTS)
        }
      EOT
    }
    state-write = {
      description = "Terraform state object written, deleted, or restored."
      pattern     = <<-EOT
        {
          ($.eventSource = "s3.amazonaws.com")
          && ($.requestParameters.bucketName = "${aws_s3_bucket.this.id}")
          && ($.errorCode NOT EXISTS)
          && (
            (
              (
                ($.eventName = "PutObject*")
                || ($.eventName = "CopyObject")
                || ($.eventName = "CompleteMultipartUpload")
                || ($.eventName = "DeleteObject")
                || ($.eventName = "DeleteObjectTagging")
                || ($.eventName = "RestoreObject")
              )
              && ($.requestParameters.key != "*.tflock")
            )
            || ($.eventName = "DeleteObjects")
          )
        }
      EOT
    }
    access-denied = {
      description = "Access denied on the state bucket, log bucket, or state KMS key."
      pattern     = <<-EOT
        {
          (
            ($.errorCode = "AccessDenied")
            || ($.errorCode = "AccessDeniedException")
          )
          && (
            (
              ($.eventSource = "s3.amazonaws.com")
              && (
                ($.requestParameters.bucketName = "${aws_s3_bucket.this.id}")
                || ($.requestParameters.bucketName = "${aws_s3_bucket.logs.id}")
              )
            )
            || (
              ($.eventSource = "kms.amazonaws.com")
              && (
                ($.resources[0].ARN = "${aws_kms_key.this.arn}")
                || ($.requestParameters.keyId = "${aws_kms_key.this.arn}")
                || ($.requestParameters.keyId = "${aws_kms_key.this.key_id}")
                || ($.requestParameters.keyId = "${aws_kms_alias.this.name}")
              )
            )
          )
        }
      EOT
    }
    s3-management = {
      description = "Mutating management event on the state or log bucket."
      pattern     = <<-EOT
        {
          ($.eventSource = "s3.amazonaws.com")
          && ($.eventCategory = "Management")
          && ($.readOnly IS FALSE)
          && (
            ($.requestParameters.bucketName = "${aws_s3_bucket.this.id}")
            || ($.requestParameters.bucketName = "${aws_s3_bucket.logs.id}")
          )
        }
      EOT
    }
    kms-management = {
      description = "Mutating management event on the state or monitoring KMS key."
      pattern     = <<-EOT
        {
          ($.eventSource = "kms.amazonaws.com")
          && ($.readOnly IS FALSE)
          && ${join(" && ", [for op in local.monitoring_kms_crypto_ops : "($.eventName != \"${op}\")"])}
          && (
            ($.resources[0].ARN = "${aws_kms_key.this.arn}")
            || ($.resources[0].ARN = "${aws_kms_key.monitoring.arn}")
            || ($.requestParameters.aliasName = "${aws_kms_alias.this.name}")
            || ($.requestParameters.aliasName = "${local.monitoring_kms_alias}")
          )
        }
      EOT
    }
    cloudtrail-tamper = {
      description = "Mutating event on the tfstate CloudTrail trail (e.g. StopLogging, DeleteTrail, PutEventSelectors)."
      pattern     = <<-EOT
        {
          ($.eventSource = "cloudtrail.amazonaws.com")
          && ($.readOnly IS FALSE)
          && (
            ($.requestParameters.name = "${local.cloudtrail_name}")
            || ($.requestParameters.name = "${local.cloudtrail_arn}")
            || ($.requestParameters.trailName = "${local.cloudtrail_name}")
            || ($.requestParameters.trailName = "${local.cloudtrail_arn}")
          )
        }
      EOT
    }
    logs-tamper = {
      description = "Mutating event on the CloudTrail log group (e.g. DeleteLogGroup, DeleteMetricFilter, PutRetentionPolicy)."
      pattern     = <<-EOT
        {
          ($.eventSource = "logs.amazonaws.com")
          && ($.readOnly IS FALSE)
          && ($.eventName != "CreateLogStream")
          && (
            ($.requestParameters.logGroupName = "${local.monitoring_log_group_name}")
            || ($.requestParameters.logGroupIdentifier = "${local.monitoring_log_group_name}")
            || ($.requestParameters.logGroupIdentifier = "${local.monitoring_log_group_arn}")
          )
        }
      EOT
    }
    alarm-tamper = {
      description = "Mutating event on a tfstate alarm, or any DeleteAlarms/DisableAlarmActions call."
      pattern     = <<-EOT
        {
          ($.eventSource = "monitoring.amazonaws.com")
          && ($.readOnly IS FALSE)
          && (
            ($.eventName = "DeleteAlarms")
            || ($.eventName = "DisableAlarmActions")
            || ($.requestParameters.alarmName = "${local.monitoring_alarm_prefix}*")
          )
        }
      EOT
    }
    sns-tamper = {
      description = "Mutating event on the alert SNS topic or its subscriptions (e.g. DeleteTopic, Unsubscribe)."
      pattern     = <<-EOT
        {
          ($.eventSource = "sns.amazonaws.com")
          && ($.readOnly IS FALSE)
          && ($.eventName != "Publish")
          && (
            ($.requestParameters.topicArn = "${local.monitoring_topic_arn}")
            || ($.requestParameters.resourceArn = "${local.monitoring_topic_arn}")
            || ($.requestParameters.subscriptionArn = "${local.monitoring_topic_arn}:*")
          )
        }
      EOT
    }
    events-tamper = {
      description = "Mutating event on the tamper-detection EventBridge rule (e.g. DisableRule, RemoveTargets)."
      pattern     = <<-EOT
        {
          ($.eventSource = "events.amazonaws.com")
          && ($.readOnly IS FALSE)
          && (
            ($.requestParameters.name = "${local.monitoring_rule_name}")
            || ($.requestParameters.rule = "${local.monitoring_rule_name}")
          )
        }
      EOT
    }
  }
}

// Data ========================================================================
data "aws_iam_policy_document" "kms_key_monitoring" {
  statement { // AllowKeyAdministration
    sid       = "AllowKeyAdministration"
    effect    = "Allow"
    resources = ["*"]
    actions   = local.kms_admin_actions

    principals {
      type        = "AWS"
      identifiers = var.admin_principal_arns
    }
  }

  statement { // AllowKeyMetadataRead
    // Needed to permit `terraform plan` to refresh aws_kms_key.monitoring without granting key usage.
    sid       = "AllowKeyMetadataRead"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:DescribeKey",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:ListResourceTags",
    ]

    principals {
      type        = "AWS"
      identifiers = local.state_principal_arns
    }
  }

  statement { // AllowKeyUsageViaSNS
    // Lets admins `aws sns publish` test messages to the encrypted topic.
    sid       = "AllowKeyUsageViaSNS"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
    ]

    principals {
      type        = "AWS"
      identifiers = var.admin_principal_arns
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["sns.${data.aws_region.this.region}.amazonaws.com"]
    }
  }

  statement { // AllowCloudWatchLogsEncryption
    sid       = "AllowCloudWatchLogsEncryption"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:Decrypt*",
      "kms:Describe*",
      "kms:Encrypt*",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
    ]

    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.this.region}.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = [local.monitoring_log_group_arn]
    }
  }

  statement { // AllowAlertPublishing
    sid       = "AllowAlertPublishing"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
    ]

    principals {
      type = "Service"
      identifiers = [
        "cloudwatch.amazonaws.com",
        "events.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "sns_alerts" {
  statement { // AllowAlarmPublishing
    sid       = "AllowAlarmPublishing"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [local.monitoring_topic_arn]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [local.monitoring_alarm_arn_glob]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.this.account_id]
    }
  }

  statement { // AllowEventPublishing
    sid       = "AllowEventPublishing"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [local.monitoring_topic_arn]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [local.monitoring_rule_arn]
    }
  }

  statement { // DenyTopicAdministrationToNonAdmins
    sid       = "DenyTopicAdministrationToNonAdmins"
    effect    = "Deny"
    resources = [local.monitoring_topic_arn]
    actions = [
      "sns:AddPermission",
      "sns:DeleteTopic",
      "sns:PutDataProtectionPolicy",
      "sns:RemovePermission",
      "sns:SetTopicAttributes",
      "sns:Subscribe",
      "sns:TagResource",
      "sns:UntagResource",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "ArnNotEquals"
      variable = "aws:PrincipalArn"
      values   = var.admin_principal_arns
    }
  }
}

data "aws_iam_policy_document" "monitoring_readonly" {
  statement { // DenyMonitoringMutation
    // Non-admin state principals may refresh (read) the monitoring pipeline, but not change it.
    sid    = "DenyMonitoringMutation"
    effect = "Deny"
    not_actions = [
      "cloudtrail:Describe*",
      "cloudtrail:Get*",
      "cloudtrail:List*",
      "cloudtrail:LookupEvents",
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "events:Describe*",
      "events:List*",
      "iam:Get*",
      "iam:List*",
      "logs:Describe*",
      "logs:FilterLogEvents",
      "logs:Get*",
      "logs:List*",
      "sns:Get*",
      "sns:List*",
    ]
    resources = [
      local.cloudtrail_arn,
      local.monitoring_alarm_arn_glob,
      local.monitoring_log_group_arn,
      "${local.monitoring_log_group_arn}:*",
      local.monitoring_rule_arn,
      local.monitoring_topic_arn,
      "${local.monitoring_topic_arn}:*",
      aws_iam_role.cloudtrail_logs.arn,
      "arn:aws:iam::${data.aws_caller_identity.this.account_id}:policy/${local.namespace}-iam-policy-monitoring-readonly",
    ]
  }
}

data "aws_iam_policy_document" "cloudtrail_logs_assume_role" {
  statement { // AllowCloudtrailAssumeRole
    sid     = "AllowCloudtrailAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.cloudtrail_arn]
    }
  }
}

data "aws_iam_policy_document" "cloudtrail_logs" {
  statement { // AllowLogStream
    sid       = "AllowLogStream"
    effect    = "Allow"
    resources = ["${aws_cloudwatch_log_group.cloudtrail.arn}:log-stream:*"]
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
}

// Resources ===================================================================
resource "aws_kms_key" "monitoring" {
  description             = "KMS key for tfstate monitoring (CloudTrail log group and alert SNS topic)."
  enable_key_rotation     = true
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.kms_key_monitoring.json
  tags                    = { Name = "${local.namespace}-kms-key-monitoring" }
}

resource "aws_kms_alias" "monitoring" {
  name          = local.monitoring_kms_alias
  target_key_id = aws_kms_key.monitoring.key_id
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = local.monitoring_log_group_name
  retention_in_days = 90 // Long-term copy lives in aws_s3_bucket.logs
  kms_key_id        = aws_kms_key.monitoring.arn
  tags              = { Name = local.monitoring_log_group_name }
}

resource "aws_iam_role" "cloudtrail_logs" {
  name               = "${local.namespace}-iam-role-cloudtrail-logs"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_logs_assume_role.json
  tags               = { Name = "${local.namespace}-iam-role-cloudtrail-logs" }
}

resource "aws_iam_role_policy" "cloudtrail_logs" {
  name   = "${local.namespace}-iam-policy-cloudtrail-logs"
  role   = aws_iam_role.cloudtrail_logs.id
  policy = data.aws_iam_policy_document.cloudtrail_logs.json
}

resource "aws_iam_policy" "monitoring_readonly" {
  name        = "${local.namespace}-iam-policy-monitoring-readonly"
  description = "Denies non-admin tfstate principals any change to the tfstate monitoring pipeline."
  policy      = data.aws_iam_policy_document.monitoring_readonly.json
  tags        = { Name = "${local.namespace}-iam-policy-monitoring-readonly" }
}

resource "aws_iam_role_policy_attachment" "monitoring_readonly" {
  for_each   = local.monitoring_readonly_role_names
  role       = each.value
  policy_arn = aws_iam_policy.monitoring_readonly.arn
}

resource "aws_sns_topic" "alerts" {
  name              = local.monitoring_topic_name
  kms_master_key_id = aws_kms_key.monitoring.arn
  tags              = { Name = local.monitoring_topic_name }
}

resource "aws_sns_topic_policy" "alerts" {
  arn    = aws_sns_topic.alerts.arn
  policy = data.aws_iam_policy_document.sns_alerts.json
}

resource "aws_sns_topic_subscription" "alerts" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = local.owner
}

resource "aws_cloudwatch_log_metric_filter" "this" {
  for_each       = local.monitoring_alarms
  name           = "${local.namespace}-metric-filter-${each.key}"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
  pattern        = replace(trimspace(each.value.pattern), "/\\s+/", " ")

  metric_transformation {
    name      = each.key
    namespace = local.namespace
    value     = "1"
    unit      = "Count"
  }
}

resource "aws_cloudwatch_metric_alarm" "this" {
  for_each            = local.monitoring_alarms
  alarm_name          = "${local.monitoring_alarm_prefix}${each.key}"
  alarm_description   = "${each.value.description} See CloudTrail log group ${local.monitoring_log_group_name}."
  namespace           = local.namespace
  metric_name         = aws_cloudwatch_log_metric_filter.this[each.key].metric_transformation[0].name
  statistic           = "Sum"
  unit                = "Count"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  tags                = { Name = "${local.monitoring_alarm_prefix}${each.key}" }
}

resource "aws_cloudwatch_event_rule" "tamper" {
  // Second, independent path for tamper alerts: fires in near real time and survives DisableAlarmActions.
  name        = local.monitoring_rule_name
  description = "Alert on changes to the tfstate monitoring pipeline."
  tags        = { Name = local.monitoring_rule_name }

  event_pattern = jsonencode({
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      "$or" = [
        {
          eventSource       = ["cloudtrail.amazonaws.com"]
          requestParameters = { name = [local.cloudtrail_name, local.cloudtrail_arn] }
        },
        {
          eventSource       = ["cloudtrail.amazonaws.com"]
          requestParameters = { trailName = [local.cloudtrail_name, local.cloudtrail_arn] }
        },
        {
          eventSource       = ["logs.amazonaws.com"]
          eventName         = [{ anything-but = "CreateLogStream" }]
          requestParameters = { logGroupName = [local.monitoring_log_group_name] }
        },
        {
          eventSource       = ["logs.amazonaws.com"]
          requestParameters = { logGroupIdentifier = [local.monitoring_log_group_name, local.monitoring_log_group_arn] }
        },
        {
          eventSource = ["monitoring.amazonaws.com"]
          eventName   = ["DeleteAlarms", "DisableAlarmActions"]
        },
        {
          eventSource       = ["monitoring.amazonaws.com"]
          requestParameters = { alarmName = [{ prefix = local.monitoring_alarm_prefix }] }
        },
        {
          eventSource       = ["sns.amazonaws.com"]
          eventName         = [{ anything-but = "Publish" }]
          requestParameters = { topicArn = [local.monitoring_topic_arn] }
        },
        {
          eventSource       = ["sns.amazonaws.com"]
          requestParameters = { subscriptionArn = [{ prefix = "${local.monitoring_topic_arn}:" }] }
        },
        {
          eventSource       = ["events.amazonaws.com"]
          requestParameters = { name = [local.monitoring_rule_name] }
        },
        {
          eventSource       = ["events.amazonaws.com"]
          requestParameters = { rule = [local.monitoring_rule_name] }
        },
        {
          eventSource       = ["kms.amazonaws.com"]
          eventName         = [{ anything-but = local.monitoring_kms_crypto_ops }]
          requestParameters = { keyId = [aws_kms_key.monitoring.arn, aws_kms_key.monitoring.key_id, local.monitoring_kms_alias] }
        },
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "tamper" {
  rule = aws_cloudwatch_event_rule.tamper.name
  arn  = aws_sns_topic.alerts.arn
}

// Outputs =====================================================================
output "aws_sns_topic_alerts_arn" {
  description = "ARN of the SNS topic receiving tfstate alerts."
  value       = aws_sns_topic.alerts.arn
}
