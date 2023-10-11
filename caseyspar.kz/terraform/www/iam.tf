###############################################################################
# AWS IAM
#

## Data =======================================================================
data "aws_kms_alias" "lambda" {
  name = "alias/aws/lambda"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_ses_sendemail" {
  statement {
    effect = "Allow"
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    resources = ["arn:aws:ses:::*"]
  }
}

data "aws_iam_policy_document" "lambda_kms_decrypt" {
  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [data.aws_kms_alias.lambda.arn]
  }
}

## Resources ==================================================================
resource "aws_iam_role" "lambda_contact_form" { # ----------------------------- IAM role.
  name               = "lambda_contact_form"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_policy" "lambda_ses_sendemail" { # -------------------------- Policies.
  name        = "lambda_ses_sendemail"
  description = "Policy for Lambda to send emails via AWS SES."
  policy      = data.aws_iam_policy_document.lambda_ses_sendemail.json
}

resource "aws_iam_policy" "lambda_kms_decrypt" {
  name        = "lambda_kms_decrypt"
  description = "Policy for Lambda to use KMS keys with S3 artifacts bucket."
  policy      = data.aws_iam_policy_document.lambda_kms_decrypt.json
}

resource "aws_iam_role_policy_attachment" "lambda_ses_sendemail" { # ---------- Policy attachments.
  role       = aws_iam_role.lambda_contact_form.name
  policy_arn = aws_iam_policy.lambda_ses_sendemail.arn
}

resource "aws_iam_role_policy_attachment" "lambda_kms_decrypt" {
  role       = aws_iam_role.lambda_contact_form.name
  policy_arn = aws_iam_policy.lambda_kms_decrypt.arn
}
