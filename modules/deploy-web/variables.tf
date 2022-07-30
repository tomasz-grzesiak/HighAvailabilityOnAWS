variable "codepipeline_role_arn" {
  type        = string
  description = "ARN of the IAM Role for CodePipeline Service"
}

variable "codebuild_role_arn" {
  type        = string
  description = "ARN of the IAM Role for CodeBuild Service"
}

variable "avbank_web_eventbridge_role_arn" {
  type        = string
  description = "ARN of the IAM Role for Web tier EventBridge Rule"
}

variable "avbank_web_repo_arn" {
  type        = string
  description = "ARN of the web tier app repo"
}