# www.caseyspar.kz
This module contains the complete configuration (static pages and Terraform configs) for
[www.caseyspar.kz](https://www.caseyspar.kz).

The site made with JAMstack and uses a Tailwinds CSS/Alpine.js frontend with a Lambda backend.

Applying this Terraform module will deploy:
* S3 buckets for the redirect root and subdomain static site pages.
* A Lambda function for the contact page backend.
* An API gateway to receive POST requests from the contact page.
* Cloudflare records to:
    * Resolve the website.
    * Verify the root domain with AWS SES.
    * Deploy DKIM keys to the subdomain.
    * Deploy SPF policy to the subdomain.

## Requirements
This directory presumes access to, and a familiarity with, the following tools:
* [AWS CLI](https://aws.amazon.com/cli/)
* [Hugo](https://gohugo.io/)
* [Node.js](https://nodejs.org/)
* [npm](https://npmjs.com/)


## Prerequisites
1. Run `npm install` from `./srv` to install NodeJS dependencies.
2. Make sure the Docker service is running on your host.
3. Ensure that you are logged into the AWS CLI with either:
    * The credentials set in your Terraform variables, or
    * Sufficient credentials to write to the S3 bucket created by [s3.tf](./s3.tf).
