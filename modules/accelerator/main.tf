terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.28.0"
      configuration_aliases = [
        aws.primary,
        aws.recovery
      ]
    }
  }
}


data "aws_region" "primary" {
  provider = aws.primary
}

data "aws_region" "recovery" {
  provider = aws.recovery
}



resource "aws_globalaccelerator_accelerator" "accelerator" {
  provider = aws.primary

  name            = "avbank-acc"
  ip_address_type = "IPV4"
  enabled         = true

  attributes {
    flow_logs_enabled = false
  }
}

module "transactions_listener" {
  providers = {
    aws = aws.primary
  }

  source = "./listener"

  accelerator_id   = aws_globalaccelerator_accelerator.accelerator.id
  port             = 8081
  primary_region   = data.aws_region.primary.name
  primary_alb_arn  = var.transactions_primary_alb_arn
  recovery_region  = data.aws_region.recovery.name
  recovery_alb_arn = var.transactions_recovery_alb_arn
}

module "accounts_listener" {
  providers = {
    aws = aws.primary
  }

  source = "./listener"

  accelerator_id   = aws_globalaccelerator_accelerator.accelerator.id
  port             = 8082
  primary_region   = data.aws_region.primary.name
  primary_alb_arn  = var.accounts_primary_alb_arn
  recovery_region  = data.aws_region.recovery.name
  recovery_alb_arn = var.accounts_recovery_alb_arn
}

module "discounts_listener" {
  providers = {
    aws = aws.primary
  }

  source = "./listener"

  accelerator_id   = aws_globalaccelerator_accelerator.accelerator.id
  port             = 8083
  primary_region   = data.aws_region.primary.name
  primary_alb_arn  = var.discounts_primary_alb_arn
  recovery_region  = data.aws_region.recovery.name
  recovery_alb_arn = var.discounts_recovery_alb_arn
}
