variable "repo_arn" {
  type        = string
  description = "ARN of the CodeCommit repository to monitor"
}

variable "repo_name" {
  type        = string
  description = "Name of the CodeCommit repository to monitor"
}

variable "pipeline_arn" {
  type        = string
  description = "ARN of the CodePipeline pipeline to start on change detection"
}

