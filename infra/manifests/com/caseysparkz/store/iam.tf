################################################################################
# IAM
#

# Data =========================================================================
data "aws_iam_policy_document" "s3_read_write" {
  statement { // Allow S3 read/write
    sid = "S3BucketReadWrite"
    actions = [
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]
  }

  statement { // Allow KMS encrypt/decrypt
    sid = "S3Kms"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:ReEncrypt*",
    ]
    resources = [data.terraform_remote_state.this.outputs.aws_kms_key_arn]
  }

  statement { // Deny all actions if accuont does not have MFA
    sid       = "DenyAllActionsIfMfaNotPresent"
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["false"]
    }
  }
}

# Resources ====================================================================
resource "aws_iam_user" "this" {
  name = "${local.namespace}-iam-user"
  tags = { Name = "${local.namespace}-iam-user" }
}

resource "aws_iam_group" "this" { name = "${local.namespace}-iam-group" }

resource "aws_iam_group_policy" "s3_readwrite" {
  name   = "${local.namespace}-iam-group-policy-s3readwrite"
  group  = aws_iam_group.this.name
  policy = data.aws_iam_policy_document.s3_read_write.json
}

resource "aws_iam_group_membership" "this" {
  name  = "${local.namespace}-iam-group-membership"
  group = aws_iam_group.this.name
  users = [aws_iam_user.this.name]
}

resource "aws_iam_access_key" "this" {
  user   = aws_iam_user.this.name
  status = "Active"
}

# Outputs ======================================================================
output "aws_iam_access_keys" {
  description = "AWS access key ID and secret key for the S3 user."
  sensitive   = true
  value = {
    AWS_ACCESS_KEY_ID     = aws_iam_access_key.this.id
    AWS_SECRET_ACCESS_KEY = aws_iam_access_key.this.secret
  }
}
