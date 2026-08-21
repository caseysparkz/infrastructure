/* Policies */

locals {
  s3_arns               = ["arn:aws:s3:::*/*", "arn:aws:s3:::*"]
  s3_encryption_methods = ["AES256", "aws:kms"] // SSE-C is a ransomware vector, do not support
  disallowed_services   = ["bedrock", "nova"]
}

// Data ========================================================================
data "aws_iam_policy_document" "denied_services" {
  statement { // Block the use of the service
    sid       = "DenyDisallowedServices"
    effect    = "Deny"
    actions   = [for service in local.disallowed_services : "${service}:*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "s3_encryption" {
  statement { // Require encryption on bucket creation
    sid       = "EnforceEncryptionOnBucketCreate"
    effect    = "Deny"
    actions   = ["s3:CreateBucket"]
    resources = local.s3_arns

    condition { // Deny s3:CreateBucket without encryption
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["false"]
    }

    condition { // Deny s3:CreateBucket with unsupported encryption algs
      test     = "StringNotEqualsIfExists"
      variable = "s3:x-amz-server-side-encryption"
      values   = local.s3_encryption_methods
    }
  }

  statement { // Require encryption at rest
    sid       = "DenyUnencryptedS3Uploads"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = local.s3_arns

    condition { // Deny s3:PutObject encrypted with unsupported alg
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = local.s3_encryption_methods
    }

    condition { // Deny s3:PutOjbect unencrypted
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["false"]
    }
  }

  statement { // Require encryption in transit
    sid       = "DenyUnencryptedS3Access"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = local.s3_arns

    condition { // Deny s3:*
      test     = "Bool"
      variable = "s3:SecureTransport"
      values   = ["false"]
    }
  }
}

// Resources ===================================================================
//// AI Policy Configuration ---------------------------------------------------
resource "aws_organizations_policy" "ai_opt_out" {
  name        = "AiOptOut"
  description = "AI opt-out policy."
  type        = "AISERVICES_OPT_OUT_POLICY"
  content = jsonencode({ "services" : { "default" : { "opt_out_policy" : {
    "@@assign" : "optOut",
    "@@operators_allowed_for_child_policies" : ["@@none"]
  } } } })
  tags = { Name = "${local.namespace}-org-policy-aioptout" }
}

resource "aws_organizations_policy_attachment" "ai_opt_out" {
  policy_id = aws_organizations_policy.ai_opt_out.id
  target_id = aws_organizations_organization.this.roots[0].id
}

//// Denied Services Configuration ---------------------------------------------
resource "aws_organizations_policy" "denied_services" {
  name        = "DeniedServices"
  description = "Disallow the use of specified services."
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.denied_services.json
  tags        = { Name = "${local.namespace}-org-policy-deniedservices" }
}

resource "aws_organizations_policy_attachment" "denied_services" {
  policy_id = aws_organizations_policy.denied_services.id
  target_id = aws_organizations_organization.this.roots[0].id
}

//// S3 Encryption Configuration -----------------------------------------------
resource "aws_organizations_policy" "s3_encryption" {
  name        = "S3EncryptionConfiguration"
  description = "Require: KMS on bucket creation, encyption at rest, encryption in transit."
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.s3_encryption.json
  tags        = { Name = "${local.namespace}-org-policy-s3encryptionconfiguration" }
}

resource "aws_organizations_policy_attachment" "s3_encryption" {
  policy_id = aws_organizations_policy.s3_encryption.id
  target_id = aws_organizations_organization.this.roots[0].id
}
