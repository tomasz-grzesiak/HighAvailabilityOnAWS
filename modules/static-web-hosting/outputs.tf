output "static_web_hosting_bucket_id" {
  value       = aws_s3_bucket.static_hosting_bucket.id
  description = "ID of the bucket with static website hosting enabled"
}

output "static_web_hosting_endpoint" {
  value       = aws_s3_bucket.static_hosting_bucket.website_endpoint
  description = "Website endpoint of S3 bucket with static website hosting enabled"
}