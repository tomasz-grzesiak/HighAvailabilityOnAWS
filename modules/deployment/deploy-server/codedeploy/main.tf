terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.28.0"
    }
  }
}

resource "aws_codedeploy_app" "app" {
  compute_platform = "Server"
  name             = "${var.repo_name}_deploy_app"
}

resource "aws_codedeploy_deployment_group" "deployment_group" {
  app_name              = aws_codedeploy_app.app.name
  deployment_group_name = "${var.repo_name}_dep_group"
  service_role_arn      = var.role_arn

  deployment_config_name = "CodeDeployDefault.OneAtATime"
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  autoscaling_groups = [var.auto_scaling_group_id]

  load_balancer_info {
    target_group_info {
      name = var.target_group_name
    }
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    green_fleet_provisioning_option {
      action = "COPY_AUTO_SCALING_GROUP"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 0
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  lifecycle {
    ignore_changes = [
      autoscaling_groups
    ]
  }
}
