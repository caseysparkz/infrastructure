###############################################################################
# Variables
#

variable "aws_budget_limit" {
  description = "Dollar value for monthly AWS budget."
  sensitive   = false
  type        = string
}

variable "aws_budget_cost_unit" {
  description = "Base currency for AWS budget."
  sensitive   = false
  type        = string
  default     = "USD"
}

variable "aws_budget_subscribers" {
  description = "List of email addresses to notify on about budget forecasts."
  sensitive   = false
  type        = list(string)
}
