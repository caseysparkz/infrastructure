################################################################################
# KMS
#

# Data =========================================================================
data "aws_iam_policy_document" "aws_kms_key" {
  statement {
    sid       = "EnableIamUserPermissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = [aws_kms_key.this.arn]

    principals {
      type = "AWS"
      identifiers = [
        aws_iam_user.this.arn,
        "arn:aws:iam::${local.aws_account_id}:root",
      ]
    }
  }
}

# Resources ====================================================================
resource "aws_kms_key" "this" {
  description             = "KMS key used to encrypt ${local.namespace} S3 bucket."
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = { Name = "${local.namespace}-kms-key" }
}

resource "aws_kms_alias" "this" {
  name          = "alias/${local.namespace}-kms-key"
  target_key_id = aws_kms_key.this.id
}

resource "aws_kms_key_policy" "this" {
  key_id                             = aws_kms_key.this.id
  bypass_policy_lockout_safety_check = false
  policy                             = data.aws_iam_policy_document.aws_kms_key.json
}
