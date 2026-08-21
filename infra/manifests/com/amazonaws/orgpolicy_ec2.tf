/* Organization Policy: EC2 */

// Resources ===================================================================
resource "aws_organizations_policy" "ec2" {
  name        = "EC2"
  description = "EC2 config policy"
  type        = "DECLARATIVE_POLICY_EC2"
  content = jsonencode({
    ec2_attributes = {
      allowed_images_settings = { // Restrict which AMIs can be installed
        state = { "@@assign" = "enabled" }
        image_criteria = {
          criteria_1 = {
            deprecation_time_condition = { // Disallow deprecated AMIs
              maximum_days_since_deprecated = { "@@assign" = 0 }
            }
          }
        }
      }
      image_block_public_access = { // Disable sharing custom AMIs
        state = { "@@assign" = "block_new_sharing" }
      }
      instance_metadata_defaults = { // Require IMDSv2
        http_tokens                 = { "@@assign" = "required" }
        http_put_response_hop_limit = { "@@assign" = 16 }
        http_endpoint               = { "@@assign" = "enabled" }
        instance_metadata_tags      = { "@@assign" = "enabled" }
        http_tokens_enforced        = { "@@assign" = "enabled" }
      }
      serial_console_access = { // Disable serial console access
        status = { "@@assign" = "disabled" }
      }
      snapshot_block_public_access = { // Disable sharing EBS snapshots
        state = { "@@assign" = "block_new_sharing" }
      }
      vpc_block_public_access = {
        internet_gateway_block = { // Block inbound VPC traffic
          mode               = { "@@assign" = "block_ingress" }
          exclusions_allowed = { "@@assign" = "enabled" }
        }
      }
      vpc_encryption_control = { // Disallow unencrypted VPC traffic
        mode = { "@@assign" = "attempt_enforce" }
        exclusions = { "@@assign" = [
          "internet_gateway",
          "nat_gateway",
        ] }
      }
      // Warn user
      exception_message = { "@@assign" = "Your configuration has been blocked by organization policy as unsafe." }
    }
  })
  tags = { Name = "${local.namespace}-org-policy-ec2" }
}

resource "aws_organizations_policy_attachment" "ec2" {
  policy_id = aws_organizations_policy.ec2.id
  target_id = aws_organizations_organization.this.roots[0].id
}
