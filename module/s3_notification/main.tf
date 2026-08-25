resource "aws_s3_bucket_notification" "notify_lambda" {
  bucket = var.bucket_id

  lambda_function {
    lambda_function_arn = var.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "submissions/"
    filter_suffix       = ".json"
  }
}   