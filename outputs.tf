output "static_web_hosting_endpoint" {
  value = module.s3_buckets.static_web_hosting_endpoint
}

output "accelerator_dns_name" {
  value = module.accelerator.accelerator_dns_name
}

output "db_endpoint" {
  value = module.database.db_endpoint
}

output "read_replica_endpoint" {
  value = module.database.read_replica_endpoint
}