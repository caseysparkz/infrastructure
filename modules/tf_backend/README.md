# www.caseyspar.kz
This module contains the configuration for the site's Terraform state bucket.

It has been run independently of the broader infrastructure, and should not be run again.
This module has been retained in the repo for posterity's sake.


## Requirements
### Softwares
* [AWS](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)


### Credentials and TF_VARs
* `$TF_VAR_aws_access_key` [SENSITIVE]
* `$TF_VAR_aws_secret_key` [SENSITIVE]
* `$TF_VAR_aws_region`
* `$TF_VAR_root_domain`


## Usage
1. Ensure that the above environment variables are present and correct in your shell.
2. Apply config (`terraform apply`).

Note that this module must be run before any other modules, and should **never** exist in any parent
configuration.
