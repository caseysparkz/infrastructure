# www.caseyspar.kz
This module contains the configuration for the site's Terraform state bucket.

It has been run, and should not be run again. This module has been retained in the repo for posterity's
sake.


## Requirements
### Softwares
* [AWS](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)


### Credentials
* `$TF_VAR_aws_access_key`
* `$TF_VAR_aws_secret_key`


## Usage
1. Sign in to AWS CLI (`aws configure`).
2. Apply config (`terraform apply`).
3. Edit `providers.tf` with newly created S3 backend infrastructure.
2. Reapply config (`terraform apply`).

Note that this module must be run before any other modules, and should **never** exist in any parent
configuration.
