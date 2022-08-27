variable "accelerator_id" {
  type        = string
  description = "ID of the accelerator"
}

variable "port" {
  type        = string
  description = "Port number"
}

variable "primary_region" {
  type        = string
  description = "Name of the primary region"
}

variable "primary_alb_arn" {
  type        = string
  description = "ARN of the ALB in the primary region"
}

variable "recovery_region" {
  type        = string
  description = "Name of the recovery region"
}

variable "recovery_alb_arn" {
  type        = string
  description = "ARN of the ALB in the recovery region"
}
