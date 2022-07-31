output "codebuild_project_arn" {
  value       = aws_codebuild_project.codebuild_project.arn
  description = "ARN of the CodeBuild project"
}

output "codebuild_project_name" {
  value       = aws_codebuild_project.codebuild_project.name
  description = "Name of the CodeBuild project"
}
