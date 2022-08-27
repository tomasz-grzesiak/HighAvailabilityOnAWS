terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.28.0"
    }
  }
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
        "Resource" : flatten([for bucket in var.artifact_bucket_arns : [bucket, "${bucket}/*"]])
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "sns:Publish",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_for_codedeploy_instance_profile" {
  name = "ec2_for_codedeploy_instance_profile_${var.name_prefix}"
  role = aws_iam_role.ec2_for_codedeploy_role.name
}
