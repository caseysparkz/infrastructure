###############################################################################
# AWS IAM
#

# Data ========================================================================
data "aws_iam_policy_document" "api_gateway" { #                                Public access.
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["execute-api:Invoke"]
    resources = [aws_api_gateway_rest_api.subdomain.execution_arn]
  }
}
