# www.caseyspar.kz

This directory contains complete Terraform configurations for my domain,
([caseyspar.kz](https://caseyspar.kz)).

Root domain configs (such as root DNS) are described in the Terraform files in
this directory, and subdomain configs (such as for
[www.caseyspar.kz](https://www.caseyspar.kz)) are constructed as modules (and
included within `./main.tf`).

## Requirements

### AWS


### Cloudflare
A Cloudflare account and API key with the following scope:
* Zone:...
* Zone:...

You must have your Cloudflare API token saved as the follow environment variable:
* `TF_VAR_cloudflare_api_token`
