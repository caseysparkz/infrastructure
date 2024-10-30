###############################################################################
# AWS IAM
#
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

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  description = "IAM policy for logging from a Lambda function."
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_ses_sendemail" { # ---------- Policy attachments.
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
