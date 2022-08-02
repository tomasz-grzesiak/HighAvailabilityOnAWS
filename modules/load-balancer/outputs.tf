output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "auto_scaling_group_id" {
  value = aws_autoscaling_group.asg.id
}

output "target_group_name" {
  value = aws_lb_target_group.alb_target_group.name
}