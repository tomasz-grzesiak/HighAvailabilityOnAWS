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
  region = var.primary_region
  alias  = "primary"
}

provider "aws" {
  region = var.recovery_region
  alias  = "recovery"
}



module "repositories" {
  providers = {
    aws = aws.primary
  }

  source = "./modules/repositories"
}

module "s3_buckets" {
  providers = {
    aws = aws.primary
  }

  source = "./modules/s3-buckets"

  static_web_hosting_bucket_name = "availablebank.pl"
}

module "s3_recovery_region_buckets" {
  providers = {
    aws = aws.recovery
  }

  source = "./modules/s3-recovery-region-buckets"
}

module "deploy_web" {
  providers = {
    aws = aws.primary
  }

  source = "./modules/deployment/deploy-web"

  repo_arn  = module.repositories.avbank_web_repo_arn
  repo_name = module.repositories.avbank_web_repo_name

  static_hosting_bucket_arn = module.s3_buckets.static_web_hosting_bucket_arn

  artifact_bucket_arn  = module.s3_buckets.avbank_web_artifact_bucket_arn
  artifact_bucket_name = module.s3_buckets.avbank_web_artifact_bucket_name
}

module "sns_sqs" {
  providers = {
    aws = aws.primary
  }

  source = "./modules/sns-sqs"
}


module "transactions_server" {
  providers = {
    aws.primary = aws.primary
    aws.recovery = aws.recovery
  }

  source = "./modules/server"

  name_prefix         = "transactions"
  app_port            = 8081
  artifact_bucket_arns = [
    module.s3_buckets.avbank_transactions_artifact_bucket_arn,
    module.s3_recovery_region_buckets.avbank_transactions_artifact_bucket_arn
  ]
}



module "transactions_deployment" {
  providers = {
    aws.primary = aws.primary
    aws.recovery = aws.recovery
  }

  source = "./modules/deployment/deploy-server"

  repo_arn  = module.repositories.avbank_transactions_repo_arn
  repo_name = module.repositories.avbank_transactions_repo_name

  primary_artifact_bucket_arn  = module.s3_buckets.avbank_transactions_artifact_bucket_arn
  primary_artifact_bucket_name = module.s3_buckets.avbank_transactions_artifact_bucket_name
  recovery_artifact_bucket_arn  = module.s3_recovery_region_buckets.avbank_transactions_artifact_bucket_arn
  recovery_artifact_bucket_name = module.s3_recovery_region_buckets.avbank_transactions_artifact_bucket_name

  primary_auto_scaling_group_id = module.transactions_server.primary_auto_scaling_group_id
  primary_target_group_name     = module.transactions_server.primary_target_group_name

  recovery_auto_scaling_group_id = module.transactions_server.recovery_auto_scaling_group_id
  recovery_target_group_name     = module.transactions_server.recovery_target_group_name

  depends_on = [
    module.transactions_server
  ]
}

# module "accounts_load_balancer" {
#   providers = {
#     aws = aws.primary
#   }

#   source = "./modules/load-balancer"

#   name_prefix               = "accounts"
#   region_vpc_id             = var.primary_region_vpc_id
#   region_subnet_ids         = var.primary_region_subnet_ids
#   region_ubuntu_node_ami_id = var.primary_region_ubuntu_node_ami_id

#   max_size = 2
#   min_size = 2
#   opt_size = 2

#   app_port            = 8082
#   artifact_bucket_arn = module.s3_buckets.avbank_accounts_artifact_bucket_arn
# }

# module "accounts_deployment" {
#   providers = {
#     aws = aws.primary
#   }

#   source = "./modules/deployment/deploy-server"

#   repo_arn  = module.repositories.avbank_accounts_repo_arn
#   repo_name = module.repositories.avbank_accounts_repo_name

#   artifact_bucket_arn  = module.s3_buckets.avbank_accounts_artifact_bucket_arn
#   artifact_bucket_name = module.s3_buckets.avbank_accounts_artifact_bucket_name

#   auto_scaling_group_id = module.accounts_load_balancer.auto_scaling_group_id
#   target_group_name     = module.accounts_load_balancer.target_group_name

#   depends_on = [
#     module.accounts_load_balancer
#   ]
# }

# module "discounts_load_balancer" {
#   providers = {
#     aws = aws.primary
#   }

#   source = "./modules/load-balancer"

#   name_prefix               = "discounts"
#   region_vpc_id             = var.primary_region_vpc_id
#   region_subnet_ids         = var.primary_region_subnet_ids
#   region_ubuntu_node_ami_id = var.primary_region_ubuntu_node_ami_id

#   max_size = 2
#   min_size = 2
#   opt_size = 2

#   app_port            = 8083
#   artifact_bucket_arn = module.s3_buckets.avbank_discounts_artifact_bucket_arn
# }

# module "discounts_deployment" {
#   providers = {
#     aws = aws.primary
#   }

#   source = "./modules/deployment/deploy-server"

#   repo_arn  = module.repositories.avbank_discounts_repo_arn
#   repo_name = module.repositories.avbank_discounts_repo_name

#   artifact_bucket_arn  = module.s3_buckets.avbank_discounts_artifact_bucket_arn
#   artifact_bucket_name = module.s3_buckets.avbank_discounts_artifact_bucket_name

#   auto_scaling_group_id = module.discounts_load_balancer.auto_scaling_group_id
#   target_group_name     = module.discounts_load_balancer.target_group_name

#   depends_on = [
#     module.discounts_load_balancer
#   ]
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


