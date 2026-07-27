# `caseysparkz/monorepo`

This repository is a monorepo for everything I write.

## Software

### Required Software and Languages

* [Dagger](https://dagger.io)
    * [Go](https://go.dev/doc/install) 1.24.4+
* [Docker](https://docs.docker.com/engine/install)
   * Docker Compose
* [Python](https://www.python.org/downloads) 3.14+. Dependencies installed via `pip install .` include:
   * `ansible`
   * `boto3`
* [Terraform](https://developer.hashicorp.com/terraform/install)

### Recommended Software

* [gh](https://cli.github.com)
* [hadolint](https://hadolint.com)
* [infracost](https://www.infracost.io/docs)
* [mdl](https://github.com/markdownlint/markdownlint)
* [mlc](https://github.com/becheran/mlc)
* [shellcheck](https://github.com/koalaman/shellcheck)
* [tfschema](https://github.com/minamijoyo/tfschema)
* [trivy](https://trivy.dev/docs/latest/getting-started/installation)
* Python `[dev,test]` dependencies installed via `pip install .[all]` include:
   * `ansible-lint`
   * `ipython`
   * `mypy`
   * `pip-audit`
   * `pytest-cov`
   * `pytest`
   * `ruff`
   * `yamllint`

## Filesystem Hierarchy

* Each domain contains its own directory in the top-level repository.
* Each component (Docker images, k8s configurations, Ansible playbooks,
   Terraform configurations) has its own subdirectory under its relevant domain.

## Secrets Management

With the exception of AWS CLI credentials, all secrets should exist in AWS
Secrets Manager and be called by code.
