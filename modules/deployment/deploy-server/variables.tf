variable "repo_arn" {
  type        = string
  description = "ARN of the code repository"
}

variable "repo_name" {
  type        = string
  description = "Name of the code repository"
}


variable "primary_artifact_bucket_arn" {
  type        = string
  description = "ARN of the bucket for pipeline artifacts in the primary region"
}

variable "primary_artifact_bucket_name" {
  type        = string
  description = "Name of the bucket for pipeline artifacts in the primary region"
}

variable "recovery_artifact_bucket_arn" {
  type        = string
  description = "ARN of the bucket for pipeline artifacts in the recovery region"
}

variable "recovery_artifact_bucket_name" {
  type        = string
  description = "Name of the bucket for pipeline artifacts in the recovery region"
}


variable "primary_auto_scaling_group_id" {
  type        = string
  description = "ID of the Auto Scaling Group for CodeDeploy in the primary region"
}

variable "primary_target_group_name" {
  type        = string
  description = "Name of the Target Group for CodeDeploy in the primary region"
}


variable "recovery_auto_scaling_group_id" {
  type        = string
  description = "ID of the Auto Scaling Group for CodeDeploy in the recovery region"
}

variable "recovery_target_group_name" {
  type        = string
  description = "Name of the Target Group for CodeDeploy in the recovery region"
}
