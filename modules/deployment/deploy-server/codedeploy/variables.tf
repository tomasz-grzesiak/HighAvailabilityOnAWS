variable "repo_name" {
  type        = string
  description = "Name of the web tier app repo"
}

variable "auto_scaling_group_id" {
  type        = string
  description = "ID of the Auto Scaling Group for CodeDeploy"
}

variable "target_group_name" {
  type        = string
  description = "Name of the Target Group for CodeDeploy"
}

variable "role_arn" {
  type        = string
  description     = "ARN of the role for the CodeDeploy"
}
