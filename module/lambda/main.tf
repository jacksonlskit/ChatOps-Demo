data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = var.lambda_source_file
  output_path = "${path.module}/lambda_src/lambda_function.zip"

}

resource "aws_lambda_function" "chatops_lambda" {
  function_name    = "${var.project_name}-${var.environment}-lambda"
  role             = var.lambda_role_arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 15

  environment {
    variables = {
      BUCKET_NAME         = var.bucket_name
      SNS_TOPIC_ARN       = var.sns_topic_arn
      DISCORD_WEBHOOK_URL = var.discord_webhook_url
    }
  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFroms3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.chatops_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.bucket_name}"

}