###############################################################################
# AWS KMS
#

## Resources ==================================================================
resource "aws_kms_key" "artifacts" {
  description             = "KMS key to encrypt domain artifacts/S3 bucket objects."
  deletion_window_in_days = 30
  tags                    = merge({ service = "kms" }, local.common_tags)
}

resource "aws_kms_alias" "artifacts" {
  name          = "alias/s3/artifacts"
  target_key_id = aws_kms_key.artifacts.key_id
}
