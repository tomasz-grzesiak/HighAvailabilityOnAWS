output "primary_alb_arn" {
  value = module.primary_region_load_balancer.alb_arn
}

output "primary_auto_scaling_group_id" {
  value = module.primary_region_load_balancer.auto_scaling_group_id
}

output "primary_target_group_name" {
  value = module.primary_region_load_balancer.target_group_name
}

output "recovery_alb_arn" {
  value = module.recovery_region_load_balancer.alb_arn
}

output "recovery_auto_scaling_group_id" {
  value = module.recovery_region_load_balancer.auto_scaling_group_id
}

output "recovery_target_group_name" {
  value = module.recovery_region_load_balancer.target_group_name
}
