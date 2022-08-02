variable "repo_arn" {
  type        = string
  description = "ARN of the web tier app repo"
}

variable "repo_name" {
  type        = string
  description = "Name of the web tier app repo"
}

variable "static_hosting_bucket_arn" {
  type        = string
  description = "ARN of the bucket with static website hosting enabled"
}

variable "artifact_bucket_arn" {
  type        = string
  description = "ARN of the bucket for pipeline artifacts"
}

variable "artifact_bucket_name" {
  type        = string
  description = "Name of the bucket for pipeline artifacts"
}
