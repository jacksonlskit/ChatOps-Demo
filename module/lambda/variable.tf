variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "lambda_role_arn" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "sns_topic_arn" {
  type = string
}

variable "discord_webhook_url" {
  type = string
}

variable "lambda_source_file" {
  type = string
}
