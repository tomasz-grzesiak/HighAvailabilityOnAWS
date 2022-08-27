terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.28.0"
    }
  }
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
          var.primary_artifact_bucket_arn,
          "${var.primary_artifact_bucket_arn}/*",
          var.recovery_artifact_bucket_arn,
          "${var.recovery_artifact_bucket_arn}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket",
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ],
        "Resource" : [
          var.primary_artifact_bucket_arn,
          "${var.primary_artifact_bucket_arn}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ],
        "Resource" : [
          var.recovery_artifact_bucket_arn,
          "${var.recovery_artifact_bucket_arn}/*"
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
          var.primary_codedeploy_app_arn,
          var.primary_codedeploy_dep_group_arn,
          var.recovery_codedeploy_app_arn,
          var.recovery_codedeploy_dep_group_arn,
          "arn:aws:codedeploy:eu-south-1:942169856926:deploymentconfig:CodeDeployDefault.OneAtATime",
          "arn:aws:codedeploy:eu-central-1:942169856926:deploymentconfig:CodeDeployDefault.OneAtATime"
        ]
      },
    ]
  })
}


resource "aws_codepipeline" "code_pipeline" {
  name     = "${var.repo_name}_pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = var.primary_artifact_bucket_name
    type     = "S3"
    region   = var.primary_region
  }

  artifact_store {
    location = var.recovery_artifact_bucket_name
    type     = "S3"
    region   = var.recovery_region
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
      region          = var.primary_region
      run_order       = 1
      name            = "Deploy_primary"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["pipeline_artifact_source"]
      version         = "1"

      configuration = {
        ApplicationName     = var.primary_codedeploy_app_name
        DeploymentGroupName = var.primary_codedeploy_dep_group_name
      }
    }

    action {
      region          = var.recovery_region
      run_order       = 2
      name            = "Deploy_recovery"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["pipeline_artifact_source"]
      version         = "1"

      configuration = {
        ApplicationName     = var.recovery_codedeploy_app_name
        DeploymentGroupName = var.recovery_codedeploy_dep_group_name
      }
    }
  }

  depends_on = [
    aws_iam_role_policy.codepipeline_role_policy
  ]
}
