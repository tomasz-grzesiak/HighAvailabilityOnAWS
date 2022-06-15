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

resource "aws_security_group" "EC2_SG" {
  name        = "EC2_SG"
  description = "Allows HTTP, HTTPS and SSH from single location"
  vpc_id      = var.main_region_vpc_id

  ingress {
    description      = "HTTP connectivity"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTPS connectivity"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH connectivity (specific)"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["151.46.71.134/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "Basic_Launch_Template" {
  name = "Basic_Launch_Template"
  image_id = "ami-0811f38eb070bf860"
  instance_type = "t3.micro"
  key_name = "milan-key"
  disable_api_termination = true
  update_default_version = true

  network_interfaces {
    device_index = 0
    associate_public_ip_address = true # czy EC2 mogą być prywatne? health check w obrębie target_group się wywala
    delete_on_termination = true
    security_groups = [
      aws_security_group.EC2_SG.id
    ]
  }
  user_data = filebase64("./ec2_run_apache.sh")
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
    aws_security_group.EC2_SG.id
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