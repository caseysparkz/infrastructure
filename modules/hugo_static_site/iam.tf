###############################################################################
# AWS IAM
#
locals {
  aws_region     = data.aws_region.current.name
  aws_account_id = data.aws_caller_identity.current.account_id
}

# Data ========================================================================
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
    resources = [
      aws_ses_domain_identity.root_domain.arn,
      aws_ses_email_identity.default_recipient.arn,
      aws_ses_email_identity.default_sender.arn
    ]
  }
}

data "aws_iam_policy_document" "lambda_kms_decrypt" {
  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [data.aws_kms_alias.lambda.arn]
  }
}

data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    #resources = ["${aws_cloudwatch_log_group.lambda_contact_form.arn}:*"]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

# Resources ===================================================================
# IAM role --------------------------------------------------------------------
resource "aws_iam_role" "lambda_contact_form" {
  name               = "lambda_contact_form"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# Policies --------------------------------------------------------------------
resource "aws_iam_policy" "lambda_ses_sendemail" {
  name        = "lambda_ses_sendemail"
  description = "Policy for Lambda to send emails via AWS SES."
  policy      = data.aws_iam_policy_document.lambda_ses_sendemail.json
}

resource "aws_iam_policy" "lambda_kms_decrypt" {
  name        = "lambda_kms_decrypt"
  description = "Policy for Lambda to use KMS keys with S3 artifacts bucket."
  policy      = data.aws_iam_policy_document.lambda_kms_decrypt.json
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  description = "IAM policy for logging from a Lambda function."
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

# Policy attachments ----------------------------------------------------------
resource "aws_iam_role_policy_attachment" "lambda_ses_sendemail" {
  role       = aws_iam_role.lambda_contact_form.name
  policy_arn = aws_iam_policy.lambda_ses_sendemail.arn
}

resource "aws_iam_role_policy_attachment" "lambda_kms_decrypt" {
  role       = aws_iam_role.lambda_contact_form.name
  policy_arn = aws_iam_policy.lambda_kms_decrypt.arn
}

resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role       = aws_iam_role.lambda_contact_form.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
