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

# module "transactions_load_balancer" {
#   source = "./modules/load-balancer"

#   name_prefix = "transactions"
#   region            = var.main_region
#   region_vpc_id     = var.main_region_vpc_id
#   region_subnet_ids = var.main_region_subnet_ids
#   region_ubuntu_node_ami_id  = var.main_region_ubuntu_node_ami_id
#   app_port          = 8081

#   max_size = 2
#   min_size = 2
#   opt_size = 2
# }