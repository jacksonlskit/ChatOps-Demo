variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "ChatOps"
}

variable "environment" {
  description = "The environment to deploy resources in"
  type        = string
  default     = "Demo"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "The availability zone to deploy resources in"
  type        = string
  default     = "us-east-1a"
}

variable "allowed_ssh_cidr" {
  description = "The CIDR block allowed to access the EC2 instance via SSH"
  type        = string
  default     = "0.0.0.0/0"
}

variable "bucket_name" {
  description = "The name of the S3 bucket to create"
  type        = string
  default     = "chatops-demo-bucket"
}

variable "sns_topic_name" {
  description = "The name of the SNS topic to create"
  type        = string
  default     = "chatOps-topic"
}

#---------------------------------------------------------------

#phase 2

variable "instance_type" {
  description = "The type of EC2 instance to launch"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair name for SSH"
  type        = string

}

variable "discord_webhook_url" {
  description = "The Discord webhook URL for sending notifications"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "Root domain name"
  default     = "www.chatops-demo.com"
}

variable "chatops_subdomain" {
  type        = string
  description = "ChatOps DNS name"
  default     = "www"

}

variable "hosted_zone_name" {
    type = string
    description = "hosted_zone_name"
    default = "sctp-sandbox.com"
  
}

variable "record_name" {
  type        = string
  description = "Full DNS record name"
  default = "chatops-demo.sctp-sandbox.com"
}

variable "telegram_bot_token" {
  type = string
  description = "telegrambot token"
  sensitive = true
  
}

variable "telegram_chat_id" {
  type = string
  description = "telegam chat id"
  sensitive = true
  
}