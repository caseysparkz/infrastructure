###############################################################################
# Providers
#

mock_provider "aws" {
  mock_data "aws_region" {
    defaults = { name = "us-west-2" }
  }
}
