output "codedeploy_app_name" {
  value       = aws_codedeploy_app.app.name
  description = "Name of the CodeDeploy Application"
}

output "codedeploy_app_arn" {
  value       = aws_codedeploy_app.app.arn
  description = "ARN of the CodeDeploy Application"
}


output "codedeploy_dep_group_name" {
  value       = aws_codedeploy_deployment_group.deployment_group.deployment_group_name
  description = "Name of the CodeDeploy Deployment Group"
}

output "codedeploy_dep_group_arn" {
  value       = aws_codedeploy_deployment_group.deployment_group.arn
  description = "ARN of the CodeDeploy Deployment Group"
}
