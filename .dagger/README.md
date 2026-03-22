# Dagger CI

This directory contains the configuration for the
[Dagger.io](https://dagger.io) CI system.

## Requirements

### System Requirements

* Python 3.13+
* `dagger` CLI
* `aws` CLI

### Environment Variables

```sh
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION=us-west-2
```

To configure these within an AWS SSO session, run:

```sh
export AWS_REGION='us-west-2'
eval $(aws configure export-credentials --format env)
```
