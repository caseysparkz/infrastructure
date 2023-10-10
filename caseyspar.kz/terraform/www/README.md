# www.caseyspar.kz
This module contains the complete configuration (static pages and Terraform configs) for
[www.caseyspar.kz](https://www.caseyspar.kz).

The site made with JAMstack and uses a Tailwinds CSS/Alpine.js frontend with a Lambda backend.

Applying this Terraform module will deploy:
* S3 buckets for the redirect root and subdomain site pages.
* A Lambda function for the contact page backend.
* An API gateway to receive POST requests from the contact page.
* Cloudflare records to:
    * Resolve the website.
    * Verify the subdomain with AWS SES.
    * Deploy DKIM keys to the subdomain.
    * Deploy SPF policy to the subdomain.
* Deploy the static pages to the S3 bucket (via the local-exec provisioner).

## Requirements
This directory presumes access to, and a familiarity with, the following tools:

### Softwares
* [Hugo](https://gohugo.io/installation/)
* [Yarn](https://classic.yarnpkg.com/lang/en/docs/install/#debian-stable)


### Credentials
* [AWS access via the AWS CLI](https://docs.aws.amazon.com/signin/latest/userguide/command-line-sign-in.html)
    * Required for deploying static pages via the local-exec provisioner.
