output "avbank_web_repo_arn" {
  value       = aws_codecommit_repository.avbank_web_repo.arn
  description = "ARN of the web tier app repo"
}

output "avbank_web_repo_name" {
  value       = aws_codecommit_repository.avbank_web_repo.repository_name
  description = "Name of the web tier app repo"
}

output "avbank_transactions_repo_id" {
  value       = aws_codecommit_repository.avbank_transactions_repo.repository_id
  description = "ID of the transactions service repo"
}

output "avbank_accounts_repo_id" {
  value       = aws_codecommit_repository.avbank_accounts_repo.repository_id
  description = "ID of the accounts service repo"
}

output "avbank_discounts_repo_id" {
  value       = aws_codecommit_repository.avbank_discounts_repo.repository_id
  description = "ID of the discounts service repo"
}