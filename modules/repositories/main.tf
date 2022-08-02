terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

resource "aws_codecommit_repository" "avbank_web_repo" {
  repository_name = "avbank_web"
  description     = "Web tier app for the AvailableBank project"
}

resource "aws_codecommit_repository" "avbank_transactions_repo" {
  repository_name = "avbank_transactions"
  description     = "Transactions service for the AvailableBank project"
}

resource "aws_codecommit_repository" "avbank_accounts_repo" {
  repository_name = "avbank_accounts"
  description     = "Accounts service for the AvailableBank project"
}

resource "aws_codecommit_repository" "avbank_discounts_repo" {
  repository_name = "avbank_discounts"
  description     = "Discounts service for the AvailableBank project"
}