output "primary_alb_dns_name" {
  value = module.primary_region_load_balancer.alb_dns_name
}

output "primary_auto_scaling_group_id" {
  value = module.primary_region_load_balancer.auto_scaling_group_id
}

output "primary_target_group_name" {
  value = module.primary_region_load_balancer.target_group_name
}

output "recovery_alb_dns_name" {
  value = module.recovery_region_load_balancer.alb_dns_name
}

output "recovery_auto_scaling_group_id" {
  value = module.recovery_region_load_balancer.auto_scaling_group_id
}

output "recovery_target_group_name" {
  value = module.recovery_region_load_balancer.target_group_name
}
