terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

resource "aws_iam_role" "codepipeline_role" {
  name = "CodePipelineRole_${var.repo_name}"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codepipeline.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_role_policy" {
  name = "codepipeline_policy_${var.repo_name}"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObjectAcl",
          "s3:PutObject"
        ],
        "Resource" : [
          var.artifact_bucket_arn,
          "${var.artifact_bucket_arn}/*"
        ]
      },
      {
        "Action" : [
          "codecommit:CancelUploadArchive",
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:GetRepository",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:UploadArchive"
        ],
        "Resource" : [
          var.repo_arn
        ],
        "Effect" : "Allow"
      },
      {
        "Effect" : "Allow"
        "Action" : [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision"
        ],
        "Resource" : [
          module.codedeploy_server.codedeploy_app_arn,
          module.codedeploy_server.codedeploy_dep_group_arn,
          "arn:aws:codedeploy:eu-south-1:942169856926:deploymentconfig:CodeDeployDefault.OneAtATime"
        ]
      },
    ]
  })
}


resource "aws_codepipeline" "code_pipeline" {
  name     = "${var.repo_name}_pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location = var.artifact_bucket_name
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["pipeline_artifact_source"]

      configuration = {
        RepositoryName = var.repo_name
        BranchName     = "master"
        PollForSourceChanges : false
        OutputArtifactFormat : "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["pipeline_artifact_source"]
      version         = "1"

      configuration = {
        ApplicationName     = module.codedeploy_server.codedeploy_app_name
        DeploymentGroupName = module.codedeploy_server.codedeploy_dep_group_name
      }
    }
  }
}

module "eventbridge_rule" {
  source = "../cloudwatch_event_detect_repo_changes"

  repo_arn     = var.repo_arn
  repo_name    = var.repo_name
  pipeline_arn = aws_codepipeline.code_pipeline.arn
}

module "codedeploy_server" {
  source = "./codedeploy-server"

  repo_name             = var.repo_name
  auto_scaling_group_id = var.auto_scaling_group_id
  target_group_name     = var.target_group_name
}

# module "codebuild_project" {
#   source = "./web-codebuild"

#   repo_name                    = var.repo_name
#   pipeline_artifact_bucket_arn = var.artifact_bucket_arn
#   static_hosting_bucket_arn    = var.static_hosting_bucket_arn
# }


