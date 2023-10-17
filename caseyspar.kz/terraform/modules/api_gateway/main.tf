###############################################################################
# Main
#

locals {
  gateway_fqdn = "${aws_api_gateway_rest_api.subdomain.id}.execute-api.${data.aws_region.current.name}.amazonaws.com"
}

# Data ========================================================================
data "aws_region" "current" {}
