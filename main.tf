terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = var.main_region
}

module "repositories" {
  source = "./modules/repositories"
}

module "static_web_hosting" {
  source = "./modules/static-web-hosting"

  bucket_name = "availablebank.pl"
}

module "deploy_web" {
  source = "./modules/deploy-web"

  avbank_web_repo_arn       = module.repositories.avbank_web_repo_arn
  avbank_web_repo_name      = module.repositories.avbank_web_repo_name
  static_hosting_bucket_arn = module.static_web_hosting.static_web_hosting_bucket_arn
}

module "sns_sqs" {
  source = "./modules/sns-sqs"
}