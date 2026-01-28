# caseysparkz/infrastructure

This repository is a monorepo for all infrastructure in my personal domain.

## Filesystem Hierarchy

* Each domain contains its own directory in the top-level repository.
* Each component (Docker images, k8s configurations, Ansible playbooks,
   Terraform configurations) has its own subdirectory under its relevant domain
   and directory.

## Secrets Management

With the exception of your AWS CLI credentials, _**all**_ secrets should exist
in AWS Secrets Manager and be called by code.

## Dependencies

### Required Software

* [Terraform](https://developer.hashicorp.com/terraform/install)
* [Python 3.13+]() <!-- TODO -->
   * Install Python dependencies with `pip install -e .[dev]`
* [NodeJS]() <!-- TODO -->
   * [npm]() <!-- TODO -->
   * [Hugo]() <!-- TODO -->

### Recommend Software

* [Mdlint]() <!-- TODO -->
* [Yamllint]() <!-- TODO -->
* [GitHub CLI]() <!-- TODO -->
   * [nektos/act]() <!-- TODO -->
