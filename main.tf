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

module "s3_buckets" {
  source = "./modules/s3-buckets"

  static_web_hosting_bucket_name = "availablebank.pl"
}

module "deploy_web" {
  source = "./modules/deployment/deploy-web"

  repo_arn  = module.repositories.avbank_web_repo_arn
  repo_name = module.repositories.avbank_web_repo_name

  static_hosting_bucket_arn = module.s3_buckets.static_web_hosting_bucket_arn

  artifact_bucket_arn  = module.s3_buckets.avbank_web_artifact_bucket_arn
  artifact_bucket_name = module.s3_buckets.avbank_web_artifact_bucket_name
}

module "sns_sqs" {
  source = "./modules/sns-sqs"
}

module "transactions_load_balancer" {
  source = "./modules/load-balancer"

  name_prefix               = "transactions"
  region_vpc_id             = var.main_region_vpc_id
  region_subnet_ids         = var.main_region_subnet_ids
  region_ubuntu_node_ami_id = var.main_region_ubuntu_node_ami_id

  max_size = 2
  min_size = 2
  opt_size = 2

  app_port            = 8081
  artifact_bucket_arn = module.s3_buckets.avbank_transactions_artifact_bucket_arn
}

module "transactions_deployment" {
  source = "./modules/deployment/deploy-server"

  repo_arn  = module.repositories.avbank_transactions_repo_arn
  repo_name = module.repositories.avbank_transactions_repo_name

  artifact_bucket_arn  = module.s3_buckets.avbank_transactions_artifact_bucket_arn
  artifact_bucket_name = module.s3_buckets.avbank_transactions_artifact_bucket_name

  auto_scaling_group_id = module.transactions_load_balancer.auto_scaling_group_id
  target_group_name     = module.transactions_load_balancer.target_group_name
}

module "accounts_load_balancer" {
  source = "./modules/load-balancer"

  name_prefix               = "accounts"
  region_vpc_id             = var.main_region_vpc_id
  region_subnet_ids         = var.main_region_subnet_ids
  region_ubuntu_node_ami_id = var.main_region_ubuntu_node_ami_id

  max_size = 2
  min_size = 2
  opt_size = 2

  app_port            = 8082
  artifact_bucket_arn = module.s3_buckets.avbank_accounts_artifact_bucket_arn
}

# module "accounts_deployment" {
#   source = "./modules/deployment/deploy-server"

#   repo_arn  = module.repositories.avbank_accounts_repo_arn
#   repo_name = module.repositories.avbank_accounts_repo_name

#   artifact_bucket_arn  = module.s3_buckets.avbank_accounts_artifact_bucket_arn
#   artifact_bucket_name = module.s3_buckets.avbank_accounts_artifact_bucket_name

#   auto_scaling_group_id = module.accounts_load_balancer.auto_scaling_group_id
#   target_group_name     = module.accounts_load_balancer.target_group_name
# }

# 1. repositories
# 2a. s3 buckets: static web hosting & artifact buckets for pipelines
# 2b. web tier - deploy
# 3a. server resources (ELB, ASG, ...)
# 3b. server tier - deploy
# (x3 for three servers)
# 4a. ...
# 4b. ...
# 5a. ...
# 5b. ...
# 6. SNS & sqs
# 7. GLobal accelerator
# 8. baza danych
