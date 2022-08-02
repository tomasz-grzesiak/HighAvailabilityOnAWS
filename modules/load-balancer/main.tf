resource "aws_security_group" "asg_security_group" {
  name        = "${var.name_prefix}_asg_security_group"
  description = "Allows HTTP connections from Application Load Balancer"
  vpc_id      = var.region_vpc_id
}

resource "aws_security_group_rule" "asg_security_group_rule_in" {
  security_group_id        = aws_security_group.asg_security_group.id
  type                     = "ingress"
  description              = "HTTP connectivity"
  from_port                = var.app_port
  to_port                  = var.app_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_security_group.id
}

resource "aws_security_group_rule" "asg_security_group_rule_in_ssh" {
  security_group_id = aws_security_group.asg_security_group.id
  type              = "ingress"
  description       = "SSH connectivity"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_security_group_rule" "asg_security_group_rule_out" {
  security_group_id = aws_security_group.asg_security_group.id
  type              = "egress"
  description       = "Outside connectivity for npm packages installation"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "alb_security_group" {
  name        = "${var.name_prefix}_alb_security_group"
  description = "Allows HTTP connections from outside and HTTP connections to asg_security_group"
  vpc_id      = var.region_vpc_id
}

resource "aws_security_group_rule" "alb_security_group_rule_in" {
  security_group_id = aws_security_group.alb_security_group.id
  type              = "ingress"
  description       = "Incoming HTTP connections"
  from_port         = var.app_port
  to_port           = var.app_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_security_group_rule_out" {
  security_group_id        = aws_security_group.alb_security_group.id
  type                     = "egress"
  description              = "Forwarding HTTP connections to instances in asg_security_group"
  from_port                = var.app_port
  to_port                  = var.app_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.asg_security_group.id
}

resource "aws_iam_role" "ec2_for_codedeploy_role" {
  name = "EC2ForCodeDeployRole_${var.name_prefix}"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ec2_for_codedeploy_role_policy" {
  role = aws_iam_role.ec2_for_codedeploy_role.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:Get*",
          "s3:List*"
        ],
        "Effect" : "Allow",
        "Resource" : [
          var.artifact_bucket_arn,
          "${var.artifact_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_for_codedeploy_instance_profile" {
  name = "ec2_for_codedeploy_instance_profile_${var.name_prefix}"
  role = aws_iam_role.ec2_for_codedeploy_role.name
}

resource "aws_launch_template" "asg_launch_template" {
  name                    = "${var.name_prefix}_asg_launch_template"
  image_id                = var.region_ubuntu_node_ami_id
  instance_type           = "t3.micro"
  disable_api_termination = false
  update_default_version  = true

  key_name = "milan-key"

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_for_codedeploy_instance_profile.arn
  }

  network_interfaces {
    device_index                = 0
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups = [
      aws_security_group.asg_security_group.id
    ]
  }
}


resource "aws_autoscaling_group" "asg" {
  name                = "${var.name_prefix}_asg"
  vpc_zone_identifier = var.region_subnet_ids
  desired_capacity    = var.opt_size
  max_size            = var.max_size
  min_size            = var.min_size

  launch_template {
    id      = aws_launch_template.asg_launch_template.id
    version = "$Default"
  }

  health_check_grace_period = 300
  health_check_type         = "ELB"
  target_group_arns = [
    aws_lb_target_group.alb_target_group.arn
  ]

  lifecycle {
      ignore_changes = [
        desired_capacity,
        max_size,
        min_size
      ]
  }
}

resource "aws_lb" "alb" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.alb_security_group.id
  ]
  subnets                          = var.region_subnet_ids
  enable_cross_zone_load_balancing = true
}

resource "aws_lb_target_group" "alb_target_group" {
  name                 = "${var.name_prefix}-alb-target-group"
  target_type          = "instance"
  port                 = var.app_port
  protocol             = "HTTP"
  vpc_id               = var.region_vpc_id
  deregistration_delay = 15

  health_check {
    enabled  = true
    path     = "/"
    interval = 10
    matcher  = "200"
    port     = var.app_port
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}
