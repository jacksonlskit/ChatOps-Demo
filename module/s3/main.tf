resource "aws_s3_bucket" "chatdemo_s3" {
  bucket = var.bucket_name

  tags = {
    Name        = "${var.project_name}-${var.environment}-s3"
    Project     = var.project_name
    Environment = var.environment
  }

}

resource "aws_s3_bucket_versioning" "chatdemo_s3_versioning" {
  bucket = aws_s3_bucket.chatdemo_s3.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "chatdemo_s3_public_access_block" {
  bucket = aws_s3_bucket.chatdemo_s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

