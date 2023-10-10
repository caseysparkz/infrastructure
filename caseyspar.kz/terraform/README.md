# www.caseyspar.kz
This directory contains complete Terraform configurations for my domain,
([caseyspar.kz](https://caseyspar.kz)).

Root domain configs (such as root DNS) are described in the Terraform files in this directory, and subdomain
configs (such as for [www.caseyspar.kz](https://www.caseyspar.kz)) are constructed as modules (and included within
`./main.tf`).


## Requirements
### AWS
An AWS account and access key/secret key pair with the following scope in your region of choice:
* 

You must be logged into the AWS CLI prior to deployment.
You must have your  access key and secret key saved as the following respective environment variables:
* `TF_VAR_aws_access_key`
* `TF_VAR_aws_secret_key`


### Cloudflare
A Cloudflare account and API key with the following scope:
* Zone:...
* Zone:...

You must have your Cloudflare API token saved as the follow environment variable:
* `TF_VAR_cloudflare_api_token`
