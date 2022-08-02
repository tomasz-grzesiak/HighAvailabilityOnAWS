output "static_web_hosting_endpoint" {
  value = module.s3_buckets.static_web_hosting_endpoint
}

output "transactions_alb_dns_name" {
  value = module.transactions_load_balancer.alb_dns_name
}