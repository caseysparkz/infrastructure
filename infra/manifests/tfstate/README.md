# Terraform State

This directory contains the configuration for the AWS S3 bucket for all
Terraform states within my domain.

## Requirements

### Software

* [AWS][aws]
* [Terraform][tf]

## Usage

The bucket already exists, and its state is stored in itself (key
`tfstate.tfstate`). Apply changes as normal with `terraform apply`.

To bootstrap the bucket from scratch:

1. Ensure your AWS credentials are present and correct in your shell.
1. Comment out the `backend` configuration block in `providers.tf`.
1. Apply the configuration (`terraform apply`).
1. Uncomment the `backend` configuration block in `providers.tf`.
1. Migrate the local state to the bucket (`terraform init -migrate-state`).

## Access Control

Access is restricted by the bucket policy (deny-only) and the KMS key policy.
Within these bounds, each principal's IAM policy decides what it can do.

| Variable                    | State files       | Lock files (`*.tflock`) | KMS key (via S3) | Bucket/key admin |
| --------------------------- | ----------------- | ----------------------- | ---------------- | ---------------- |
| `var.reader_principal_arns` | Read              | Read/write/delete       | Use              | -                |
| `var.writer_principal_arns` | Read/write/delete | Read/write/delete       | Use              | -                |
| `var.admin_principal_arns`  | -                 | -                       | -                | Yes              |

Whoever runs `terraform apply` here must be in both `var.admin_principal_arns`
and `var.writer_principal_arns`, since this configuration's own state lives in
the bucket. If locked out of the bucket, the account root user can always
delete the bucket policy.
