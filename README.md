# caseysparkz/infrastructure

This repository is a monorepo for all infrastructure in my personal domain.

## Requirements

* Terraform
* Infracost
* Docker
* Hadolint
* Python 3.14+
  * Python dependencies installed via `pip install .[all]`

## Filesystem Hierarchy

* Each domain contains its own directory in the top-level repository.
* Each component (Docker images, k8s configurations, Ansible playbooks,
   Terraform configurations) has its own subdirectory under its relevant domain.

## Secrets Management

With the exception of your AWS CLI credentials, all secrets should exist in AWS
Secrets Manager and be called by code.
