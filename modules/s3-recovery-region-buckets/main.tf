terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.28.0"
    }
  }
}


resource "aws_s3_bucket" "avbank_transactions_artifact_bucket" {
  bucket = "recovery-avbank-transactions-artifact"
}

resource "aws_s3_bucket" "avbank_accounts_artifact_bucket" {
  bucket = "recovery-avbank-accounts-artifacts"
}

resource "aws_s3_bucket" "avbank_discounts_artifact_bucket" {
  bucket = "recovery-avbank-discounts-artifacts"
}
