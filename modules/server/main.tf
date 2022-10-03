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

locals {
  primary_region_vpc_id             = "<VPC ID>"
  primary_region_subnet_ids         = "<List of subnet IDs in VPC>"
  primary_region_ubuntu_node_ami_id = "<AMI ID in VPC>"
  primary_region_instance_type      = "<Instance type>"
  primary_region_ssh_key_name       = "<SSH key name>"

  recovery_region_vpc_id             = "<VPC ID>"
  recovery_region_subnet_ids         = "<List of subnet IDs in VPC>"
  recovery_region_ubuntu_node_ami_id = "<AMI ID in VPC>"
  recovery_region_instance_type      = "<Instance type>"
  recovery_region_ssh_key_name       = "<SSH key name>"
}


module "ec2_instance_profile" {
  providers = {
    aws = aws.primary
  }

  source = "./ec2-instance-profile"

  name_prefix          = var.name_prefix
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
