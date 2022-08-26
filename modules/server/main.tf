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

locals {
  primary_region_vpc_id             = "vpc-0601da11524bf785c"
  primary_region_subnet_ids         = ["subnet-019da7f8f722b2b86", "subnet-0fe54a4794495f74d", "subnet-0ab4b8c5a7a9e9695"]
  primary_region_ubuntu_node_ami_id = "ami-0e1d316f4f8e8d71a"
  primary_region_instance_type      = "t3.micro"
  primary_region_ssh_key_name       = "milan-key"

  recovery_region_vpc_id             = "vpc-0a8b3956e0bb88f20"
  recovery_region_subnet_ids         = ["subnet-01ae5520532376616", "subnet-0dece85d7b93cff86", "subnet-0103ce8a929bede1d"]
  recovery_region_ubuntu_node_ami_id = "ami-08158fed44d99082b"
  recovery_region_instance_type      = "t2.micro"
  recovery_region_ssh_key_name       = "frankfurt-key"
}


module "ec2_instance_profile" {
  providers = {
    aws = aws.primary
  }

  source = "./ec2-instance-profile"

  name_prefix         = var.name_prefix
  artifact_bucket_arns = var.artifact_bucket_arns
}


module "primary_region_load_balancer" {
  providers = {
    aws = aws.primary
  }

  source = "./load-balancer"

  name_prefix               = var.name_prefix
  instance_type             = local.primary_region_instance_type
  region_vpc_id             = local.primary_region_vpc_id
  region_subnet_ids         = local.primary_region_subnet_ids
  region_ubuntu_node_ami_id = local.primary_region_ubuntu_node_ami_id
  ssh_key_name              = local.primary_region_ssh_key_name

  max_size = 2
  min_size = 2
  opt_size = 2

  app_port                 = var.app_port
  ec2_instance_profile_arn = module.ec2_instance_profile.ec2_instance_profile_arn
}

module "recovery_region_load_balancer" {
  providers = {
    aws = aws.recovery
  }

  source = "./load-balancer"

  name_prefix               = var.name_prefix
  instance_type             = local.recovery_region_instance_type
  region_vpc_id             = local.recovery_region_vpc_id
  region_subnet_ids         = local.recovery_region_subnet_ids
  region_ubuntu_node_ami_id = local.recovery_region_ubuntu_node_ami_id
  ssh_key_name              = local.recovery_region_ssh_key_name

  max_size = 1
  min_size = 1
  opt_size = 1

  app_port                 = var.app_port
  ec2_instance_profile_arn = module.ec2_instance_profile.ec2_instance_profile_arn
}
