variable "pipeline_artifact_bucket_arn" {
  type        = string
  description = "ARN of the artifact bucket used by CodePipeline"
}

variable "repo_name" {
  type        = string
  description = "Name of the repository to build"
}

variable "static_hosting_bucket_arn" {
  type        = string
  description = "ARN of the bucket with static website hosting enabled"
}
