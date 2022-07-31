resource "aws_iam_role" "codebuild_role" {
  name = "CodeBuildRole"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codebuild.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_role_policy" {
  role = aws_iam_role.codebuild_role.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:*"
        ],
        "Resource" : [
          var.pipeline_artifact_bucket_arn,
          "${var.pipeline_artifact_bucket_arn}/*",
          var.static_hosting_bucket_arn,
          "${var.static_hosting_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_codebuild_project" "codebuild_project" {
  name         = "${var.repo_name}_build_project"
  description  = "Build project for the ${var.repo_name} repository"
  service_role = aws_iam_role.codebuild_role.arn

  source {
    type            = "CODEPIPELINE"
    git_clone_depth = 1
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type = "NO_CACHE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  build_timeout = "15"

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  source_version = "master"
}
