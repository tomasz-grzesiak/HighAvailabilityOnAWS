output "ec2_instance_profile_arn" {
  value = aws_iam_instance_profile.ec2_for_codedeploy_instance_profile.arn
}
