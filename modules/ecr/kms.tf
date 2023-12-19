###############################################################################
# KMS
#

## Resources ==================================================================
resource "aws_kms_key" "ecr" {
  description             = "Key used to encrypt ECR images."
  deletion_window_in_days = 30
  tags                    = local.common_tags
}

resource "aws_kms_alias" "ecr" {
  name          = "alias/ecr_kms_key"
  target_key_id = aws_kms_key.ecr.key_id
}
