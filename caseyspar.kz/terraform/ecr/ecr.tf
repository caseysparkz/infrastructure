###############################################################################
# ECR
#
resource "aws_ecr_repository" "ecr" { #                                         ECR repo.
  name                 = var.root_domain
  image_tag_mutability = "IMMUTABLE"
  force_delete         = false
  tags                 = local.common_tags

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecr.arn
  }
  image_scanning_configuration {
    scan_on_push = true
  }
}
