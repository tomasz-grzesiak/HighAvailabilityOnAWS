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
  value       = aws_s3_bucket.avbank_discounts_artifact_bucket.id
  description = "Name of the arifact bucket for the avbank_discounts deployment"
}
