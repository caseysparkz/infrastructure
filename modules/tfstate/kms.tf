################################################################################
# AWS KMS
#

# Resources ====================================================================
resource "aws_kms_key" "terraform_state" {
  description             = "KMS key for terraform state S3 bucket objects."
  deletion_window_in_days = 30
  tags                    = { service = "kms" }
}

resource "aws_kms_alias" "terraform_state" {
  name          = "alias/${replace(var.bucket_name, ".", "/")}"
  target_key_id = aws_kms_key.terraform_state.key_id
}
