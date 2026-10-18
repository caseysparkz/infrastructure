/* KMS */

locals {
  kms_admin_actions = [
    "kms:CancelKeyDeletion",
    "kms:Create*",
    "kms:Delete*",
    "kms:Describe*",
    "kms:Disable*",
    "kms:Enable*",
    "kms:Get*",
    "kms:List*",
    "kms:Put*",
    "kms:Revoke*",
    "kms:RotateKeyOnDemand",
    "kms:ScheduleKeyDeletion",
    "kms:TagResource",
    "kms:UntagResource",
    "kms:Update*",
  ]
}

// Data ========================================================================
data "aws_iam_policy_document" "kms_key" {
  statement { // KeyAdministration
    sid       = "KeyAdministration"
    effect    = "Allow"
    resources = ["*"]
    actions   = local.kms_admin_actions

    principals {
      type        = "AWS"
      identifiers = var.admin_principal_arns
    }
  }

  statement { // KeyMetadataRead
    // Allows `terraform plan` to refresh aws_kms_key.this without granting key usage.
    sid       = "KeyMetadataRead"
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

  statement { // KeyUsageViaS3
    sid       = "KeyUsageViaS3"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
    ]

    principals {
      type        = "AWS"
      identifiers = local.state_principal_arns
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["s3.${data.aws_region.this.region}.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.this.account_id]
    }
  }
}

// Resources ===================================================================
resource "aws_kms_key" "this" {
  description             = "KMS key for terraform state S3 bucket objects."
  enable_key_rotation     = true
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.kms_key.json
  tags                    = { Name = "${local.namespace}-kms-key" }
}

resource "aws_kms_alias" "this" {
  name          = "alias/${local.namespace}-kms-key"
  target_key_id = aws_kms_key.this.key_id
}

// Outputs =====================================================================
output "aws_kms_key_arn" {
  description = "ARN of the KMS key used to encrypt tfstate."
  value       = aws_kms_key.this.arn
  sensitive   = true
}
