###############################################################################
# AWS IAM
#

# Data ========================================================================
data "aws_iam_policy_document" "api_gateway" {
  statement {
    effect    = "Allow"
    actions   = ["execute-api:Invoke"]
    resources = [aws_api_gateway_rest_api.subdomain.execution_arn]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}
