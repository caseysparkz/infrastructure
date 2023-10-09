########################################################################################################################
# ECR
#

resource "aws_ecr_repository" "ecr" {
  for_each = toset([
    for f in fileset(local.dockerfile_dir, "*") : replace(f, "/:.*$/", "")
  ])
  name                 = each.key
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true
  tags                 = local.common_tags

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecr.arn
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}
