variable "avbank_web_repo_arn" {
  type        = string
  description = "ARN of the web tier app repo"
}

variable "avbank_web_repo_name" {
  type        = string
  description = "Name of the web tier app repo"
}

variable "static_hosting_bucket_arn" {
  type        = string
  description = "ARN of the bucket with static website hosting enabled"
}