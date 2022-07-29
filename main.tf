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