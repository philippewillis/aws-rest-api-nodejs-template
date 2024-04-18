resource "aws_s3_bucket" "rest_api_source" {
  bucket        = local.bucket_name
  force_destroy = true
  tags = {
    Name        = "Source code for API Gateway/Lambda proxy resource"
    Environment = terraform.workspace
  }
}

resource "aws_s3_bucket_acl" "rest_api_source" {
  bucket     = aws_s3_bucket.rest_api_source.bucket
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.rest_api_source]
}

data "archive_file" "rest_api_source" {
  type        = "zip"
  source_dir  = "../../build"
  output_path = "../../dist/${path.module}/rest-api-source.zip"
}

resource "aws_s3_object" "rest_api_source" {
  bucket = aws_s3_bucket.rest_api_source.id
  key    = "rest-api-source.zip"
  source = data.archive_file.rest_api_source.output_path
  etag   = filemd5(data.archive_file.rest_api_source.output_path)
}

resource "aws_s3_bucket_ownership_controls" "rest_api_source" {
  bucket = aws_s3_bucket.rest_api_source.id
  rule {
    object_ownership = "ObjectWriter"
  }
}