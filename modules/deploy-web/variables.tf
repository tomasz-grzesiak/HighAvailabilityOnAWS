variable "codepipeline_role_arn" {
  type        = string
  description = "ARN of the IAM Role for CodePipeline Service"
}


variable "codebuild_role_arn" {
  type        = string
  description = "ARN of the IAM Role for CodeBuild Service"
}