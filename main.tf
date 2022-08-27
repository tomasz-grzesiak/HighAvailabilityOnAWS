terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.28.0"    }
  }
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


# module "transactions_server" {
#   providers = {
#     aws.primary  = aws.primary
#     aws.recovery = aws.recovery
#   }

#   source = "./modules/server"

#   name_prefix = "transactions"
#   app_port    = 8081
#   artifact_bucket_arns = [
#     module.s3_buckets.avbank_transactions_artifact_bucket_arn,
#     module.s3_recovery_region_buckets.avbank_transactions_artifact_bucket_arn
#   ]
# }

# module "transactions_deployment" {
#   providers = {
#     aws.primary  = aws.primary
#     aws.recovery = aws.recovery
#   }

#   source = "./modules/deployment/deploy-server"

#   repo_arn  = module.repositories.avbank_transactions_repo_arn
#   repo_name = module.repositories.avbank_transactions_repo_name

#   primary_artifact_bucket_arn   = module.s3_buckets.avbank_transactions_artifact_bucket_arn
#   primary_artifact_bucket_name  = module.s3_buckets.avbank_transactions_artifact_bucket_name
#   recovery_artifact_bucket_arn  = module.s3_recovery_region_buckets.avbank_transactions_artifact_bucket_arn
#   recovery_artifact_bucket_name = module.s3_recovery_region_buckets.avbank_transactions_artifact_bucket_name

#   primary_auto_scaling_group_id = module.transactions_server.primary_auto_scaling_group_id
#   primary_target_group_name     = module.transactions_server.primary_target_group_name

#   recovery_auto_scaling_group_id = module.transactions_server.recovery_auto_scaling_group_id
#   recovery_target_group_name     = module.transactions_server.recovery_target_group_name

#   depends_on = [
#     module.transactions_server
#   ]
# }



# module "accounts_server" {
#   providers = {
#     aws.primary  = aws.primary
#     aws.recovery = aws.recovery
#   }

#   source = "./modules/server"

#   name_prefix = "accounts"
#   app_port    = 8082
#   artifact_bucket_arns = [
#     module.s3_buckets.avbank_accounts_artifact_bucket_arn,
#     module.s3_recovery_region_buckets.avbank_accounts_artifact_bucket_arn
#   ]
# }

# module "accounts_deployment" {
#   providers = {
#     aws.primary  = aws.primary
#     aws.recovery = aws.recovery
#   }

#   source = "./modules/deployment/deploy-server"

#   repo_arn  = module.repositories.avbank_accounts_repo_arn
#   repo_name = module.repositories.avbank_accounts_repo_name

#   primary_artifact_bucket_arn   = module.s3_buckets.avbank_accounts_artifact_bucket_arn
#   primary_artifact_bucket_name  = module.s3_buckets.avbank_accounts_artifact_bucket_name
#   recovery_artifact_bucket_arn  = module.s3_recovery_region_buckets.avbank_accounts_artifact_bucket_arn
#   recovery_artifact_bucket_name = module.s3_recovery_region_buckets.avbank_accounts_artifact_bucket_name

#   primary_auto_scaling_group_id = module.accounts_server.primary_auto_scaling_group_id
#   primary_target_group_name     = module.accounts_server.primary_target_group_name

#   recovery_auto_scaling_group_id = module.accounts_server.recovery_auto_scaling_group_id
#   recovery_target_group_name     = module.accounts_server.recovery_target_group_name

#   depends_on = [
#     module.accounts_server
#   ]
# }



# module "discounts_server" {
#   providers = {
#     aws.primary  = aws.primary
#     aws.recovery = aws.recovery
#   }

#   source = "./modules/server"

#   name_prefix = "discounts"
#   app_port    = 8083
#   artifact_bucket_arns = [
#     module.s3_buckets.avbank_discounts_artifact_bucket_arn,
#     module.s3_recovery_region_buckets.avbank_discounts_artifact_bucket_arn
#   ]
# }

# module "discounts_deployment" {
#   providers = {
#     aws.primary  = aws.primary
#     aws.recovery = aws.recovery
#   }

#   source = "./modules/deployment/deploy-server"

#   repo_arn  = module.repositories.avbank_discounts_repo_arn
#   repo_name = module.repositories.avbank_discounts_repo_name

#   primary_artifact_bucket_arn   = module.s3_buckets.avbank_discounts_artifact_bucket_arn
#   primary_artifact_bucket_name  = module.s3_buckets.avbank_discounts_artifact_bucket_name
#   recovery_artifact_bucket_arn  = module.s3_recovery_region_buckets.avbank_discounts_artifact_bucket_arn
#   recovery_artifact_bucket_name = module.s3_recovery_region_buckets.avbank_discounts_artifact_bucket_name

#   primary_auto_scaling_group_id = module.discounts_server.primary_auto_scaling_group_id
#   primary_target_group_name     = module.discounts_server.primary_target_group_name

#   recovery_auto_scaling_group_id = module.discounts_server.recovery_auto_scaling_group_id
#   recovery_target_group_name     = module.discounts_server.recovery_target_group_name

#   depends_on = [
#     module.discounts_server
#   ]
# }


# module "accelerator" {
#   providers = {
#     aws.primary = aws.primary
#     aws.recovery = aws.recovery
#   }

#   source = "./modules/accelerator"

#   transactions_primary_alb_arn = module.transactions_server.primary_alb_arn
#   transactions_recovery_alb_arn = module.transactions_server.recovery_alb_arn

#   accounts_primary_alb_arn = module.accounts_server.primary_alb_arn
#   accounts_recovery_alb_arn = module.accounts_server.recovery_alb_arn

#   discounts_primary_alb_arn = module.discounts_server.primary_alb_arn
#   discounts_recovery_alb_arn = module.discounts_server.recovery_alb_arn

#   depends_on = [
#     module.transactions_server,
#     module.accounts_server,
#     module.discounts_server
#   ]
# }


# module "database" {
#   providers = {
#     aws.primary = aws.primary
#     aws.recovery = aws.recovery
#   }

#   source = "./modules/database"
# }

