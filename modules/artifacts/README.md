# www.caseyspar.kz
This module contains the configuration for the site's Terraform state bucket.


## Requirements
This directory presumes access to, and a familiarity with, the following tools:

### Softwares
* [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)


### Credentials
* AWS access key
* AWS secret key


## Usage
**1. Set working directory, and sign in to AWS CLI.**
```
export INFRA_DIR="$(git rev-parse --show-toplevel)/caseyspar.kz/terraform/infrastructure"
    && cd "${INFRA_DIR}/"

aws configure                                                                   # Region: us-west-2.
```

**2. Apply the Terraform configuration.**
```
terraform apply                                                                 # Apply Terraform configuration.
```

Note that this module must be run before any other modules, and should not exist in the root `main.tf`.
