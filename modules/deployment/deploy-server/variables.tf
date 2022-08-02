variable "repo_arn" {
  type        = string
  description = "ARN of the code repository"
}

variable "repo_name" {
  type        = string
  description = "Name of the code repository"
}


variable "artifact_bucket_arn" {
  type        = string
  description = "ARN of the bucket for pipeline artifacts"
}

variable "artifact_bucket_name" {
  type        = string
  description = "Name of the bucket for pipeline artifacts"
}


variable "auto_scaling_group_id" {
  type        = string
  description = "ID of the Auto Scaling Group for CodeDeploy"
}

variable "target_group_name" {
  type        = string
  description = "Name of the Target Group for CodeDeploy"
}
