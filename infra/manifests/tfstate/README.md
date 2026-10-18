# Terraform State

This directory contains the configuration for the AWS S3 bucket for all
Terraform states within my domain.

## Requirements

### Software

* [AWS][aws]
* [Terraform][tf]

## Usage

The bucket already exists, and its state is stored in itself (S3 object key
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

| Variable                | tfstate | lockfiles | KMS | S3/KMS Admin | Monitor |
| :---------------------- | :------ | :-------- | :-- | :----------- | :------ |
| `reader_principal_arns` | `r`     | `r/w`     | Use | -            | `r`     |
| `writer_principal_arns` | `r/w`   | `r/w`     | Use | -            | `r`     |
| `admin_principal_arns`  | -       | -         | -   | Yes          | `r/w`   |

"Monitoring" is the trail, log group, alarms, EventBridge rule, and SNS topic.
Non-admin reader/writer roles get `aws_iam_policy.monitoring_readonly`
attached, which denies every non-read action on those resources.

Whoever runs `terraform apply` here must be in both `var.admin_principal_arns`
and `var.writer_principal_arns`, since this configuration's own state lives in
the bucket. If locked out of the bucket, the account root user can always
delete the bucket policy.

## Monitoring

The CloudTrail trail delivers to a KMS-encrypted CloudWatch Logs group. Metric
filters on that group drive CloudWatch alarms, which notify the SNS topic
`aws_sns_topic.alerts` (subscribers: `var.alert_email_addresses`).

| Alarm               | Trigger                                  |
| :------------------ | :--------------------------------------- |
| `state-read`        | Successful `GetObject` on a state file.  |
| `state-write`       | Successful write of a state file         |
| `access-denied`     | `AccessDenied` on S3/KMS key             |
| `s3-management`     | Management event on S3                   |
| `kms-management`    | Management event on KMS                  |
| `cloudtrail-tamper` | Change to the trail                      |
| `logs-tamper`       | Change to the log group                  |
| `alarm-tamper`      | Change to the alarms                     |
| `sns-tamper`        | Change to the topic or its subscriptions |
| `events-tamper`     | Change to the tamper EventBridge rule    |

Tamper events (trail, log group, alarms, topic, EventBridge rule, monitoring
KMS key) also reach the topic directly through the EventBridge rule
`aws_cloudwatch_event_rule.tamper`, so disabling one path still alerts via the
other. EventBridge alerts arrive within seconds; alarm alerts lag by the
CloudTrail-to-CloudWatch Logs delivery delay (typically 5-15 minutes).

Note that `state-read` fires on every `terraform plan` against any state in the
bucket, and that applying this configuration triggers the tamper alerts.

After the first apply:

1. Confirm each email subscription from the link AWS sends.
1. Prevent unauthenticated unsubscribes (the email footer link) by
   re-confirming with the token from the confirmation link:

   ```sh
   aws sns confirm-subscription                                               \
     --topic-arn "$(terraform output -raw aws_sns_topic_alerts_arn)"          \
     --token "<token>"                                                        \
     --authenticate-on-unsubscribe true
   ```

<!-- Links -->
[aws]: https://docs.aws.amazon.com/cli/
[tf]: https://developer.hashicorp.com/terraform/install
