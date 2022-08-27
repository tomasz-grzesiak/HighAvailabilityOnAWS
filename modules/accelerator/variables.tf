variable "transactions_primary_alb_arn" {
  type        = string
  description = "ARN of the transactions ALB in the primary region"
}

variable "transactions_recovery_alb_arn" {
  type        = string
  description = "ARN of the transactions ALB in the recovery region"
}

variable "accounts_primary_alb_arn" {
  type        = string
  description = "ARN of the accounts ALB in the primary region"
}

variable "accounts_recovery_alb_arn" {
  type        = string
  description = "ARN of the accounts ALB in the recovery region"
}

variable "discounts_primary_alb_arn" {
  type        = string
  description = "ARN of the discounts ALB in the primary region"
}

variable "discounts_recovery_alb_arn" {
  type        = string
  description = "ARN of the discounts ALB in the recovery region"
}
