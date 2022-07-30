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

module "roles_policies" {
  source = "./modules/roles-policies"
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

  codepipeline_role_arn = module.roles_policies.codepipeline_role_arn
  codebuild_role_arn    = module.roles_policies.codebuild_role_arn
}