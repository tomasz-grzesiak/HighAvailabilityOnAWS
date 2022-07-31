resource "aws_s3_bucket" "codepipeline_artifact_bucket" {
  bucket = "avbank-pipeline-source-artifacts"
}

resource "aws_iam_role" "codepipeline_role" {
  name = "CodePipelineRole"

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
  name = "codepipeline_policy"
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
          aws_s3_bucket.codepipeline_artifact_bucket.arn,
          "${aws_s3_bucket.codepipeline_artifact_bucket.arn}/*"
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
          var.avbank_web_repo_arn
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
  name     = "avbank_web_pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location = aws_s3_bucket.codepipeline_artifact_bucket.bucket
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
        RepositoryName = "avbank_web"
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

  repo_arn     = var.avbank_web_repo_arn
  repo_name    = var.avbank_web_repo_name
  pipeline_arn = aws_codepipeline.avbank_web_pipeline.arn
}

module "codebuild_project" {
  source = "./web-codebuild"

  repo_name                    = var.avbank_web_repo_name
  pipeline_artifact_bucket_arn = aws_s3_bucket.codepipeline_artifact_bucket.arn
  static_hosting_bucket_arn    = var.static_hosting_bucket_arn
}


