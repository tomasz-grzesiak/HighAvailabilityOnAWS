output "static_web_hosting_endpoint" {
  value = module.s3_buckets.static_web_hosting_endpoint
}

output "transactions_primary_alb_dns_name" {
  value = module.transactions_server.primary_alb_dns_name
}

output "transactions_recovery_alb_dns_name" {
  value = module.transactions_server.recovery_alb_dns_name
}

# output "accounts_alb_dns_name" {
#   value = module.accounts_load_balancer.alb_dns_name
# }

# output "discounts_alb_dns_name" {
#   value = module.discounts_load_balancer.alb_dns_name
# }