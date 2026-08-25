output "lambda_function_arn" {
  value = aws_lambda_function.chatops_lambda.arn

}

output "lambda_function_name" {
  value = aws_lambda_function.chatops_lambda.function_name

}

output "lambda_permission_statement_id" {
  value = aws_lambda_permission.allow_s3.statement_id
}