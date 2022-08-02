resource "aws_s3_bucket" "avbank_web_artifact_bucket" {
  bucket = "avbank-web-artifacts"
}

resource "aws_s3_bucket" "avbank_transactions_artifact_bucket" {
  bucket = "avbank-transactions-artifacts"
}

resource "aws_s3_bucket" "avbank_accounts_artifact_bucket" {
  bucket = "avbank-accounts-artifacts"
}

resource "aws_s3_bucket" "avbank_discounts_artifact_bucket" {
  bucket = "avbank-discounts-artifacts"
}

resource "aws_s3_bucket" "static_hosting_bucket" {
  bucket              = var.static_web_hosting_bucket_name
  object_lock_enabled = false

  website {
    error_document = "index.html"
    index_document = "index.html"
  }
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.static_hosting_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership_controls" {
  bucket = aws_s3_bucket.static_hosting_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.static_hosting_bucket.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "PublicReadGetObject",
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource" : "${aws_s3_bucket.static_hosting_bucket.arn}/*"
      }
    ]
  })
}
