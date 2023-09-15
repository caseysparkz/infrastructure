###############################################################################
# AWS KMS
#
resource "aws_kms_key" "terraform_state" {
  description             = "KMS key for terraform state S3 bucket objects."
  deletion_window_in_days = 30
  tags = merge(
    {
      service = "kms"
    },
    local.common_tags
  )
}
resource "aws_kms_alias" "terraform_state" {
  name          = "alias/terraform_state_kms_key"
  target_key_id = aws_kms_key.terraform_state.key_id
}
