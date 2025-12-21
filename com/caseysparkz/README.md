# caseysparkz.com

This directory contains complete Terraform configurations for my domain,
([caseysparkz.com](https://www.caseysparkz.com)).

Root domain configs (such as root DNS) are described in the Terraform files in
this directory, and subdomain configs (such as for
[www.caseysparkz.com](https://www.caseysparkz.com)) are constructed as modules
(and included within `./main.tf`).

## Requirements

### AWS

### Cloudflare

A Cloudflare account and API key with the following scope:

* Zone:...
* Zone:...
