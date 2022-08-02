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
        "Effect" : "Allow",
        "Action" : [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ],
        "Resource" : [
          module.codebuild_project.codebuild_project_arn
        ]
      }
    ]
  })
}


resource "aws_codepipeline" "avbank_web_pipeline" {
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
      output_artifacts = ["avbank_web_pipeline_artifact_source"]

      configuration = {
        RepositoryName = var.repo_name
        BranchName     = "master"
        PollForSourceChanges : false
        OutputArtifactFormat : "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["avbank_web_pipeline_artifact_source"]
      version         = "1"

      configuration = {
        ProjectName  = module.codebuild_project.codebuild_project_name
        BatchEnabled = false
      }
    }
  }
}

module "eventbridge_rule" {
  source = "../cloudwatch_event_detect_repo_changes"

  repo_arn     = var.repo_arn
  repo_name    = var.repo_name
  pipeline_arn = aws_codepipeline.avbank_web_pipeline.arn
}

module "codebuild_project" {
  source = "./web-codebuild"

  repo_name                    = var.repo_name
  pipeline_artifact_bucket_arn = var.artifact_bucket_arn
  static_hosting_bucket_arn    = var.static_hosting_bucket_arn
}


