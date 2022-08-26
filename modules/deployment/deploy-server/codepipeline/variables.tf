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



variable "primary_region" {
  type        = string
  description = "Name of the primary region"
}

variable "primary_codedeploy_app_arn" {
  type        = string
  description = "ARN of the CodeDeploy application in the primary region"
}

variable "primary_codedeploy_app_name" {
  type        = string
  description = "Name of the CodeDeploy application in the primary region"
}

variable "primary_codedeploy_dep_group_arn" {
  type        = string
  description = "ARN of the CodeDeploy deployment group in the primary region"
}

variable "primary_codedeploy_dep_group_name" {
  type        = string
  description = "Name of the CodeDeploy deployment group in the primary region"
}



variable "recovery_region" {
  type        = string
  description = "Name of the recovery region"
}

variable "recovery_codedeploy_app_arn" {
  type        = string
  description = "ARN of the CodeDeploy application in the recovery region"
}

variable "recovery_codedeploy_app_name" {
  type        = string
  description = "Name of the CodeDeploy application in the recovery region"
}

variable "recovery_codedeploy_dep_group_arn" {
  type        = string
  description = "ARN of the CodeDeploy deployment group in the recovery region"
}

variable "recovery_codedeploy_dep_group_name" {
  type        = string
  description = "Name of the CodeDeploy deployment group in the recovery region"
}
