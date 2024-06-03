###############################################################################
# AWS Budgets
#
locals {}

## Resources ==================================================================
resource "aws_budgets_budget" "cost" {
  name         = "aws_total_budget_monthly"
  budget_type  = "COST"
  limit_amount = var.aws_budget_limit
  limit_unit   = var.aws_budget_cost_unit
  time_unit    = "MONTHLY"
  tags         = local.common_tags

  notification {
    comparison_operator        = "EQUAL_TO"
    threshold                  = "100"
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORCASTED"
    subscriber_email_addresses = var.aws_budget_subscribers
  }
}

## Outputs ====================================================================
output "aws_cost_arn" {
  description = "ARN of the AWS cost explorer budget."
  value = aws_budgets_budget.cost.arn
  sensitive = false
}

output "aws_cost_id" {
  description = "ID of the AWS cost explorer budget."
  value = aws_budgets_budget.cost.id
  sensitive = false
}
