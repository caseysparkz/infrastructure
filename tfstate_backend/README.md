# www.caseyspar.kz
This directory contains the configuration for the AWS S3 bucket for all Terraform states I create.


## Requirements
### Softwares
* [AWS](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)


### Credentials and TF_VARs
* `$TF_VAR_aws_access_key` [SENSITIVE]
* `$TF_VAR_aws_secret_key` [SENSITIVE]


## Usage
1. Ensure that the above environment variables are present and correct in your shell.
2. Apply the configuration (`terraform apply`).
3. Un-comment the `backend` config block in `providers.tf`.
4. Repply the configuration.
