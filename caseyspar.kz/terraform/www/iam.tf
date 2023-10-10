###############################################################################
# AWS IAM
#

## Data =======================================================================
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

## Resources ==================================================================
resource "aws_iam_role" "lambda_contact_form" {
  name               = "lambda_contact_form"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_policy" "lambda_ses_sendemail" {
  name        = "lambda_contact_form"
  description = "Policy for Lambda to send emails via AWS SES."
  policy      = data.aws_iam_policy_document.lambda_ses_sendemail.json
}

resource "aws_iam_role_policy_attachment" "lambda_contact_form" {
  role       = aws_iam_role.lambda_contact_form.name
  policy_arn = aws_iam_policy.lambda_ses_sendemail.arn
}
