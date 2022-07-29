resource "aws_s3_bucket" "static_hosting_bucket" {
  bucket              = var.bucket_name
  object_lock_enabled = false
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.static_hosting_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.static_hosting_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.static_hosting_bucket.id

  policy = <<-POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.static_hosting_bucket.arn}/*"
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_website_configuration" "bucket_hosting_configuration" {
  bucket = aws_s3_bucket.static_hosting_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}