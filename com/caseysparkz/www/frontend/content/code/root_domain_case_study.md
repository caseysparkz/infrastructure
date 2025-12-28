---
title: 'Root Domain Case Study'
date: '2023-10-03T11:32:00+08:00'
draft: true
language: 'en'
summary: 'A meta case study of pure-Terraform deployments.'
featured_image: '../assets/images/posts/code/root_domain_case_study.png'
categories: 'code'
tags:
    - 'curations'
    - 'code'

---
## A Jamstack static frontend, Lambda backend, Terraformed infrastructure, and Github Actions CI/CD

[View on Github](https://github.com/caseysparkz/infrastructure)

This website is written in Tailwind CSS and Javascript, built with Hugo, and
Terraformed and deployed via Github Actions. Its backend (currently only the
_<a href="../contact">contact page</a>_) runs on AWS Lambda.

Its codebase (and the codebase for all infrustructure under my domain) is
viewable
_[here](https://github.com/caseysparkz/infrastructure/tree/main/caseysparkz.com/terraform/www)_
and relevant configurations are hyperlinked whenever mentioned.


## <u>Terraform</u>
I've been working with Terraform since 2020, when I first made the switch from system administration to
development operations.

This website (and my domain as a whole) can solely be deployed with a `terraform
apply` from the Terraform root
_[`caseysparkz.com/terraform`](https://github.com/caseysparkz/infrastructure/tree/main/caseysparkz.com/terraform)_;
this stands up all DNS for the root domain, and all infrastructure for subdomains.

### *Root Domain*

The root domain is controlled by
_[`caseysparkz.com/terraform/main.tf`](https://github.com/caseysparkz/infrastructure/blob/main/caseysparkz.com/terraform/main.tf)_
 and its supplementary Terraform configs. At a minimum, it contains the root
_[DNS
records](https://github.com/caseysparkz/infrastructure/blob/main/caseysparkz.com/terraform/main.tf)_.

Subdomains are configured as modules, and can be added or removed from the
domain root with the inclusion or exclusion of a module block in
_[`caseysparkz.com/terraform/main.tf`](https://github.com/caseysparkz/infrastructure/blob/main/caseysparkz.com/terraform/main.tf)_.

### *Subdomains*

Subdomains for the site are included in the Terraform config as modules,
allowing any given subdomain (eg: _[www.caseysparkz.com](www.caseysparkz.com)_)
to be added or removed by editing
_[`main.tf`](https://github.com/caseysparkz/infrastructure/blob/main/caseysparkz.com/terraform/main.tf)_
to include its corresponding module and outputs.

## <u>Hugo</u>

As someone with little to no proficiency in HTML, Javascript, or CSS,
_[Hugo](https://gohugo.io)_ is a huge help in standing up frontends, and
requires relatively little coding to plug in a
_[Lambda](https://aws.amazon.com/pm/lambda/)_ backend.

Having a static frontend with a Lambda backend provides advantages to both the
cost and security of the site, with the added benefit of being able to write
your backend in Java, Go, PowerShell, Node.js, C#, Python, or Ruby.

The
_[infrastructure](https://github.com/caseysparkz/infrastructure/tree/main/caseysparkz.com/terraform/infrastructure)_
module creates an `s3://artifacts` bucket in which Lambda functions can be stored.

## <u>Lamba</u>

## <u>CI/CD</u>

### *Github Actions*

## <u>Deployment</u>

If you choose to replicate this deployment, **the order in which you deploy
resources matters!**

1. Run `terraform apply` from
   `caseysparkz.com/terraform/infrastructure/tf_backend_s3`. This creates the S3
   backend for Terraform's state file.
1. Comment out all modules in `caseysparkz.com/terraform/main.tf` **except**
   `infrastructure` and run `terraform apply. This creates your root DNS and
   backend resources such as the `artifacts` S3 bucket.
1. Uncomment the remaining modules in `caseysparkz.com/terraform/main.tf`
   (as needed/desired), and run `terraform apply` once again.

### Secrets Managament
