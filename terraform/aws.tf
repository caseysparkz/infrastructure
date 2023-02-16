locals {
  common_tags = {
    terraform = ""
  }
}

resource "aws_iam_user" "cli_user" { #                                          Create AWS CLI user.
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

resource "aws_iam_access_key" "cli_user" { #                                    Create access key for CLI user.
  user = aws_iam_user.cli_user.name
}

resource "aws_iam_user_ssh_key" "cli_user" { #                                  Add SSH key to CLI user.
  username   = aws_iam_user.cli_user.name
  encoding   = "SSH"
  public_key = var.admin_ssh_pubkey
}

resource "aws_iam_user_policy" "cli_user" { #                                   Add policy to user.
  name = "${aws_iam_user.cli_user.name}_iam_policy"
  user = aws_iam_user.cli_user.name

  policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "ECRFullAccess",
                "Effect": "Allow",
                "Action": [
                    "ecr:*"
                ],
                "Resource": "*"
            }
        ]
    }
  EOF
}

resource "aws_ecr_repository" "alpine_base" { #                                 Alpine base repo.
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
      domain = var.root_domain
      ecr    = ""
      image  = "alpine"
    }
  )
}

resource "aws_ecr_repository" "python3_base" { #                                Python3 base repo.
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
      domain = var.root_domain
      ecr    = ""
      image  = "python3"
    }
  )
}

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
