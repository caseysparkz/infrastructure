locals { #                                                                              Local TF variables.
  common_tags = {
    terraform = ""
  }
}

##########################################################################################################################
# ECR Config
resource "aws_iam_user" "cli_user" { #                                                  AWS CLI user.
  name          = "cli_user"
  path          = "/"
  force_destroy = true

  tags = merge(
    local.common_tags,
    {
      iam = ""
    }
  )
}

resource "aws_iam_access_key" "cli_user" { #                                            Access key for CLI user.
  user = aws_iam_user.cli_user.name
}

resource "aws_iam_user_ssh_key" "cli_user" { #                                          Add SSH key to CLI user.
  username   = aws_iam_user.cli_user.name
  encoding   = "SSH"
  public_key = var.admin_ssh_pubkey
}

resource "aws_iam_user_policy" "cli_user" { #                                           Add policy to user.
  name = "${aws_iam_user.cli_user.name}_iam_policy"
  user = aws_iam_user.cli_user.name

  policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "ECRFullAccess",
                "Effect": "Allow",
                "Principal": "${aws_iam_user.cli_user.arn}",
                "Action": [
                    "ecr:*"
                ],
                "Resource": "*"
            }
        ]
    }
  EOF
}

resource "aws_ecr_repository" "alpine_base" { #                                         Alpine base repo.
  name                 = "alpine_base"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    local.common_tags,
    {
      domain = "ecr.${var.root_domain}"
      ecr    = ""
      image  = "alpine"
    }
  )
}

resource "aws_ecr_repository" "python3_base" { #                                        Python3 base repo.
  name                 = "python3_base"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    local.common_tags,
    {
      domain = "ecr.${var.root_domain}"
      ecr    = ""
      image  = "python3"
    }
  )
}

##########################################################################################################################
# S3 Config
resource "aws_iam_user" "s3_user" { #                                                   AWS S3 user.
  name          = "s3_user"
  path          = "/"
  force_destroy = true
  tags = merge(
    local.common_tags,
    {
      iam = ""
    }
  )
}

resource "aws_iam_access_key" "s3_user" { #                                             Access key for S3 user.
  user = aws_iam_user.s3_user.name
}

resource "aws_iam_user_policy" "s3_user" { #                                            Add policy to user.
  name = "${aws_iam_user.s3_user.name}_iam_policy"
  user = aws_iam_user.s3_user.name

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "S3Access",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
              "${aws_s3_bucket.cloud_caseyspar_kz.arn}",
              "arn:aws:s3:::cloud_caseyspar_kz",
              "arn:aws:s3:::keys.caseyspar.kz"
            ]
        }
    ]
  }
  EOF
}

resource "aws_kms_key" "cloud_key" { #                                                  Key used to encrypt S3 buckets.
  description             = "Key used to encrypt S3 buckets."
  deletion_window_in_days = 14
}

resource "aws_s3_bucket" "cloud_caseyspar_kz" { #                                       Misc. cloud storage.
  bucket = "cloud.${var.root_domain}"

  tags = merge(
    local.common_tags,
    {
      domain = "cloud.${var.root_domain}"
      s3     = ""
    }
  )
}

resource "aws_s3_bucket_acl" "cloud_caseyspar_kz" { #                                   ACL policy for cloud.caseyspar.kz.
  bucket = aws_s3_bucket.cloud_caseyspar_kz.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "cloud_caseyspar_kz" { #                   Block public S3 access.
  bucket                  = aws_s3_bucket.cloud_caseyspar_kz.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloud_caseyspar_kz" { #  S3 encryption policy.
  bucket = aws_s3_bucket.cloud_caseyspar_kz.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.cloud_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

##########################################################################################################################
# Outputs
output "aws_ecr_repository_url" {
  value = "${aws_ecr_repository.alpine_base.registry_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}

output "aws_iam_cli_user_access_key_id" {
  value     = aws_iam_access_key.cli_user.id
  sensitive = true
}

output "aws_iam_cli_user_access_key_secret" {
  value     = aws_iam_access_key.cli_user.secret
  sensitive = true
}

output "aws_iam_s3_user_access_key_id" {
  value     = aws_iam_access_key.s3_user.id
  sensitive = true
}

output "aws_iam_s3_user_access_key_secret" {
  value     = aws_iam_access_key.s3_user.secret
  sensitive = true
}
