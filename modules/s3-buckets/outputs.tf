output "avbank_web_artifact_bucket_arn" {
  value       = aws_s3_bucket.avbank_web_artifact_bucket.arn
  description = "ARN of the arifact bucket for the avbank_web deployment"
}

output "avbank_web_artifact_bucket_name" {
  value       = aws_s3_bucket.avbank_web_artifact_bucket.id
  description = "Name of the arifact bucket for the avbank_web deployment"
}


output "avbank_transactions_artifact_bucket_arn" {
  value       = aws_s3_bucket.avbank_transactions_artifact_bucket.arn
  description = "ARN of the arifact bucket for the avbank_transactions deployment"
}

output "avbank_transactions_artifact_bucket_name" {
  value       = aws_s3_bucket.avbank_transactions_artifact_bucket.id
  description = "Name of the arifact bucket for the avbank_transactions deployment"
}


output "avbank_accounts_artifact_bucket_arn" {
  value       = aws_s3_bucket.avbank_accounts_artifact_bucket.arn
  description = "ARN of the arifact bucket for the avbank_accounts deployment"
}

output "avbank_accounts_artifact_bucket_name" {
  value       = aws_s3_bucket.avbank_accounts_artifact_bucket.id
  description = "Name of the arifact bucket for the avbank_accounts deployment"
}


output "avbank_discounts_artifact_bucket_arn" {
  value       = aws_s3_bucket.avbank_discounts_artifact_bucket.arn
  description = "ARN of the arifact bucket for the avbank_discounts deployment"
}

output "avbank_discounts_artifact_bucket_name" {
  value       = aws_s3_bucket.avbank_accounts_artifact_bucket.id
  description = "Name of the arifact bucket for the avbank_discounts deployment"
}



output "static_web_hosting_bucket_arn" {
  value       = aws_s3_bucket.static_hosting_bucket.arn
  description = "ARN of the bucket with static website hosting enabled"
}

output "static_web_hosting_endpoint" {
  value       = aws_s3_bucket.static_hosting_bucket.website_endpoint
  description = "Website endpoint of S3 bucket with static website hosting enabled"
}