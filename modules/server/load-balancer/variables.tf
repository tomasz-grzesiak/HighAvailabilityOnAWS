variable "name_prefix" {
  type        = string
  description = "Prefix for resource names within module"
}

variable "instance_type" {
  type        = string
  description = "Instance type to run in Auto Scaling Group"
}

variable "region_vpc_id" {
  type        = string
  description = "Default VPC ID in the region"
}

variable "region_subnet_ids" {
  type        = list(string)
  description = "Default subnet IDs in the default VPC in the region"
}

variable "region_ubuntu_node_ami_id" {
  type        = string
  description = "Ubuntu 22 with Node 16 AMI ID in the region"
}

variable "ssh_key_name" {
  type        = string
  description = "Name of the SSH key"
}



variable "min_size" {
  type        = number
  description = "Minimal number of instances in the ASG"
}

variable "max_size" {
  type        = number
  description = "Maximal number of instances in the ASG"
}

variable "opt_size" {
  type        = number
  description = "Optimal number of instances in the ASG"
}


variable "app_port" {
  type        = number
  description = "Application port, also for ALB to listen to and forward to"
}


variable "ec2_instance_profile_arn" {
  type        = string
  description = "ARN of intance profile for EC2 instances"
}
