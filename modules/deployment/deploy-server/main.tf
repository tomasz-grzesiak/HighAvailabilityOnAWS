terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
      configuration_aliases = [
        aws.primary,
        aws.recovery
      ]
    }
  }

  required_version = ">= 0.14.9"
}

data "aws_region" "primary" {
  provider = aws.primary
}

data "aws_region" "recovery" {
  provider = aws.recovery
}


module "codedeploy_role" {
  providers = {
    aws = aws.primary
  }

  source = "./codedeploy-role"
  
  repo_name = var.repo_name
}

module "primary_codedeploy" {
  providers = {
    aws = aws.primary
  }

  source = "./codedeploy"

  repo_name             = var.repo_name
  auto_scaling_group_id = var.primary_auto_scaling_group_id
  target_group_name     = var.primary_target_group_name
  role_arn = module.codedeploy_role.codedeploy_role_arn
}

module "recovery_codedeploy" {
  providers = {
    aws = aws.recovery
  }

  source = "./codedeploy"

  repo_name             = var.repo_name
  auto_scaling_group_id = var.recovery_auto_scaling_group_id
  target_group_name     = var.recovery_target_group_name
  role_arn = module.codedeploy_role.codedeploy_role_arn
}

module "codepipeline" {
  providers = {
    aws = aws.primary
  }

  source = "./codepipeline"

  repo_arn = var.repo_arn
  repo_name = var.repo_name

  primary_artifact_bucket_arn = var.primary_artifact_bucket_arn
  primary_artifact_bucket_name = var.primary_artifact_bucket_name
  recovery_artifact_bucket_arn = var.recovery_artifact_bucket_arn
  recovery_artifact_bucket_name = var.recovery_artifact_bucket_name

  primary_region = data.aws_region.primary.name
  primary_codedeploy_app_arn = module.primary_codedeploy.codedeploy_app_arn
  primary_codedeploy_app_name = module.primary_codedeploy.codedeploy_app_name
  primary_codedeploy_dep_group_arn = module.primary_codedeploy.codedeploy_dep_group_arn
  primary_codedeploy_dep_group_name = module.primary_codedeploy.codedeploy_dep_group_name

  recovery_region = data.aws_region.recovery.name
  recovery_codedeploy_app_arn = module.recovery_codedeploy.codedeploy_app_arn
  recovery_codedeploy_app_name = module.recovery_codedeploy.codedeploy_app_name
  recovery_codedeploy_dep_group_arn = module.recovery_codedeploy.codedeploy_dep_group_arn
  recovery_codedeploy_dep_group_name = module.recovery_codedeploy.codedeploy_dep_group_name
}

module "eventbridge_rule" {
  providers = {
    aws = aws.primary
  }

  source = "../cloudwatch_event_detect_repo_changes"

  repo_arn     = var.repo_arn
  repo_name    = var.repo_name
  pipeline_arn = module.codepipeline.pipeline_arn
}


