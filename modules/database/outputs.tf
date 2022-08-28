output "db_endpoint" {
  value = aws_db_instance.database.address
}

output "read_replica_endpoint" {
  value = aws_db_instance.read_replica.address
}
