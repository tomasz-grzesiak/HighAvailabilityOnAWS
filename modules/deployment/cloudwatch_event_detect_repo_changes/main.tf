terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

resource "aws_iam_role" "eventbridge_role" {
  name = "EventBridgeRole_${var.repo_name}"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "events.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "eventbridge_role_policy" {
  role = aws_iam_role.eventbridge_role.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "codepipeline:StartPipelineExecution"
        ]
        "Resource" : [
          var.pipeline_arn
        ]
      },
    ]
  })
}

resource "aws_cloudwatch_event_rule" "detect_repo_changes" {
  name        = "detect_repo_changes_${var.repo_name}"
  description = "Detects changes made to the master branch of the ${var.repo_name} repo"

  event_pattern = jsonencode({
    "source" : ["aws.codecommit"]
    "detail-type" : ["CodeCommit Repository State Change"],
    "resources" : ["${var.repo_arn}"]
    "detail" : {
      "event" : [
        "referenceCreated",
        "referenceUpdated"
      ],
      "referenceType" : [
        "branch"
      ]
      "referenceName" : [
        "master"
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "detect_repo_changes_target" {
  target_id = "detect_web_repo_changes_target"
  rule      = aws_cloudwatch_event_rule.detect_repo_changes.name
  arn       = var.pipeline_arn

  role_arn = aws_iam_role.eventbridge_role.arn
}
