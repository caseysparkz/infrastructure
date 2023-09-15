# www.caseyspar.kz
This module contains the complete configuration (static pages and Terraform configs) for
[www.caseyspar.kz](https://www.caseyspar.kz).

The site made with JAMstack and uses a Tailwinds CSS/Alpine.js frontend with a Lambda backend.


## Requirements
This directory presumes access to, and a familiarity with, the following tools:

### Softwares
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* [Hugo](https://gohugo.io/installation/)
* [Yarn](https://classic.yarnpkg.com/lang/en/docs/install/#debian-stable)


### Credentials
* [AWS access via the AWS CLI](https://docs.aws.amazon.com/signin/latest/userguide/command-line-sign-in.html)
* [A Cloudflare API token](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/)


### Other Resources
* S3 bucket containing the Lambda function for the contact page.
    * This monorepo uses the bucket defined in `caseyspar.kz/terraform/infrastructure/artifacts`.


## Usage
**1. Set working directory and sign in to AWS CLI.**
```
export WWW_DIR="$(git rev-parse --show-toplevel)/caseyspar.kz/terraform/www"    # Set working directory.        \
    && cd "${WWW_DIR}/"

aws --profile <PROFILE_NAME> sso login                                          # Log in to your AWS account.
```

**2. Apply the Terraform configuration.**
```
terraform apply                                                                 # Apply Terraform configuration.
```

**3. Build and deploy the static site.**
```
cd "${WWW_DIR}/srv"                                                             # Switch to Hugo directory      \
    && hugo build                                                               # and build static pages.

aws --profile <PROFILE_NAME> s3 cp --recursive                                  # Copy pages to S3.             \
    ./srv                                                                                                       \
    $(terraform output -raw aws_s3_bucket_uri)
```

Once the infrastructure has been deployed, frontend changes can be deployed by performing steps one and three
only.
