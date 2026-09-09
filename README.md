# `caseysparkz/monorepo`

This repository is a monorepo for everything I write. Its focus is predominantly
infrastructure-as-code, with a view to cloud security, and CI/CD.

## Software

### Required Software and Languages

* [Dagger](https://dagger.io/)
  * [Go](https://go.dev/doc/install) 1.24.4+
* [Docker](https://docs.docker.com/engine/install)
  * Docker Compose
* [Python](https://www.python.org/downloads/) 3.13+. Dependencies installed via
  `pip install .` include:
  * `ansible`
  * `boto3`
* [Terraform](https://developer.hashicorp.com/terraform/install)

### Recommended Software

* [gh](https://cli.github.com)
* [hadolint](https://hadolint.com)
* [infracost](https://www.infracost.io/docs/)
* [mdl](https://github.com/markdownlint/markdownlint)
* [mlc](https://github.com/becheran/mlc)
* [shellcheck](https://github.com/koalaman/shellcheck)
* [tfschema](https://github.com/minamijoyo/tfschema)
* [trivy](https://trivy.dev/docs/latest/getting-started/installation/)
* Python `[dev,test]` dependencies installed via `pip install .[all]` include:
  * `ansible-lint`
  * `ipython`
  * `mypy`
  * `pip-audit`
  * `pytest-cov`
  * `pytest`
  * `ruff`
  * `yamllint`

## Repository Structure

* Each domain contains its own directory in the top-level repository.
* Each component (Docker images, k8s configurations, Ansible playbooks,
   Terraform configurations) has its own subdirectory under its relevant domain.

## Security

### Secrets Management

With the exception of AWS CLI credentials, all secrets should exist in AWS
Secrets Manager and be called by code.

### Prowler

I use Prowler internally for cloud security posture detection and management.

To exclude **known** false positives, add the tag 'Prowler=ignore' to a given
resource.

Run prowler scans against the AWS environment with:

```sh
prowler aws                                                                   \
    --region "${AWS_REGION}"                                                  \
    --profile "${AWS_PROFILE}"                                                \
    --mutelist-file .prowler_mutelist.yml                                     \
    --security-hub
```

## CI/CD

At this moment, CI/CD is split between GitHub Actions (old) and
Dagger (new). GitHub is becoming less-and-less reliable, and my CI/CD pipelines
are really the only part of my workflow with high vendor-lock-in.

I'll be fixing this over the coming weeks and months, as I move to a pure-Dagger
approach.
