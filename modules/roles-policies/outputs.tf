output "codepipeline_role_arn" {
  value       = aws_iam_role.codepipeline_role.arn
  description = "ARN of the IAM Role for CodePipeline Service"
}

output "codebuild_role_arn" {
  value       = aws_iam_role.codebuild_role.arn
  description = "ARN of the IAM Role for CodeBuild Service"
}

output "avbank_web_eventbridge_role_arn" {
  value       = aws_iam_role.avbank_web_eventbridge_role.arn
  description = "ARN of the IAM Role for Web tier EventBridge Rule"
}