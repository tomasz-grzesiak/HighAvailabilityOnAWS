terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.28.0"
    }
  }
}


resource "aws_globalaccelerator_listener" "primary_listener" {
  accelerator_arn = var.accelerator_id
  client_affinity = "NONE"
  protocol        = "TCP"

  port_range {
    from_port = var.port
    to_port   = var.port
  }
}

resource "aws_globalaccelerator_endpoint_group" "primary_endpoint_group" {
  listener_arn                  = aws_globalaccelerator_listener.primary_listener.id
  endpoint_group_region         = var.primary_region
  health_check_interval_seconds = 10
  health_check_path             = "/"
  health_check_port             = var.port
  health_check_protocol         = "TCP"
  threshold_count               = 3
  traffic_dial_percentage       = 100

  endpoint_configuration {
    endpoint_id                    = var.primary_alb_arn
    weight                         = 128
    client_ip_preservation_enabled = false
  }

  lifecycle {
    ignore_changes = [
      health_check_path
    ]
  }
}

resource "aws_globalaccelerator_endpoint_group" "recovery_endpoint_group" {
  listener_arn                  = aws_globalaccelerator_listener.primary_listener.id
  endpoint_group_region         = var.recovery_region
  health_check_interval_seconds = 10
  health_check_path             = "/"
  health_check_port             = var.port
  health_check_protocol         = "TCP"
  threshold_count               = 3
  traffic_dial_percentage       = 0

  endpoint_configuration {
    endpoint_id                    = var.recovery_alb_arn
    weight                         = 128
    client_ip_preservation_enabled = false
  }

  lifecycle {
    ignore_changes = [
      health_check_path
    ]
  }
}