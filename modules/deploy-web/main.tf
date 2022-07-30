resource "aws_s3_bucket" "codepipeline_artifact_bucket" {
  bucket = "avbank-pipeline-source-artifacts"
}

resource "aws_codebuild_project" "avbank_web_build_project" {
  name         = "avbank_web_build_project"
  description  = "Build project for the web layer of the AvailableBank project"
  service_role = var.codebuild_role_arn

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

resource "aws_codepipeline" "avbank_web_pipeline" {
  name     = "avbank_web_pipeline"
  role_arn = var.codepipeline_role_arn
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
        ProjectName  = aws_codebuild_project.avbank_web_build_project.name
        BatchEnabled = false
      }
    }
  }
}