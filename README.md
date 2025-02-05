# caseysparkz/infrastructure

This repository is a monorepo for all infrastructure in my personal domain.

## Filesystem Heirarchy

* Each domain contains its own directory in the top-level repository.
* Each component (Docker images, k8s configurations, Ansible playbooks,
   Terraform configurations) has its own subdirectory under its relevant domain.

## Secrets Management

* Terraform-specific secrets (such as AWS/Cloudflare API keys) should exist in
   the user's shell as `$TF_VAR_variable_name` variables.
* All other secrets should exist in AWS Secrets Manager and be called by code.
