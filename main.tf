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


resource "aws_security_group" "Web_SG" {
  name        = "Web_SG"
  description = "Allows HTTP connections from Application Load Balancer"
  vpc_id      = var.main_region_vpc_id
}

resource "aws_security_group_rule" "Web_SG_ingress" {
  security_group_id = aws_security_group.Web_SG.id
  type = "ingress"
  description = "HTTP connectivity"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id  = aws_security_group.ALB_SG.id
}

resource "aws_security_group" "ALB_SG" {
  name = "ALB_SG"
  description = "Allows HTTP connections from outside and HTTP connections to Web_SG"
  vpc_id = var.main_region_vpc_id
}

resource "aws_security_group_rule" "ALB_SG_ingress" {
  security_group_id = aws_security_group.ALB_SG.id
  type = "ingress"
  description = "Incoming HTTP connections"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ALB_SG_egress" {
  security_group_id = aws_security_group.ALB_SG.id
  type = "egress"
  description = "Forwarding HTTP connections to instances in Web_SG"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = aws_security_group.Web_SG.id
}

resource "aws_launch_template" "Basic_Launch_Template" {
  name = "Basic_Launch_Template"
  image_id = var.httpd_AMI
  instance_type = "t3.micro"
  key_name = "milan-key"
  disable_api_termination = true
  update_default_version = true

  network_interfaces {
    device_index = 0
    associate_public_ip_address = false
    delete_on_termination = true
    security_groups = [
      aws_security_group.Web_SG.id
    ]
  }
  user_data = filebase64("./create_distinct_file.sh")
}


resource "aws_autoscaling_group" "Basic_ASG" {
  name = "Basic_ASG"
  vpc_zone_identifier = var.main_region_subnet_ids
  desired_capacity   = 3
  max_size           = 4
  min_size           = 2

  launch_template {
    id      = aws_launch_template.Basic_Launch_Template.id
    version = "$Default"
  }

  health_check_type = "ELB"
  target_group_arns = [
    aws_lb_target_group.Basic_TG.arn
  ]
}

resource "aws_lb" "Basic_ALB" {
  name               = "BasicALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [
    aws_security_group.ALB_SG.id
  ]
  subnets            = var.main_region_subnet_ids
  enable_cross_zone_load_balancing = true
}

resource "aws_lb_target_group" "Basic_TG" {
  name     = "BasicTG"
  target_type = "instance"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.main_region_vpc_id

  health_check {
    enabled = true
    path = "/"
    interval = 30
    matcher = "200"
    port = 80
  }
}

resource "aws_lb_listener" "Basic_ALB_Listener" {
  load_balancer_arn = aws_lb.Basic_ALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Basic_TG.arn
  }
}

output "ALB_DNS_name" {
  value = aws_lb.Basic_ALB.dns_name
}