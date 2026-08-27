module "vpc" {
  source = "./module/vpc"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  availability_zone  = var.availability_zone
}

module "security_group" {
  source = "./module/security_group"

  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.public_subnet_id
  allowed_ssh_cidr = var.allowed_ssh_cidr
}

module "s3" {
  source = "./module/s3"

  project_name = var.project_name
  environment  = var.environment
  bucket_name  = var.bucket_name
}

module "sns" {
  source = "./module/sns"

  project_name   = var.project_name
  environment    = var.environment
  sns_topic_name = var.sns_topic_name
}


#---------------------------------------------------------------
#phase 2

module "iam" {
  source = "./module/iam"

  project_name  = var.project_name
  environment   = var.environment
  bucket_arn    = module.s3.bucket_arn
  sns_topic_arn = module.sns.topic_arn
}

module "lambda" {
  source = "./module/lambda"

  project_name        = var.project_name
  environment         = var.environment
  lambda_role_arn     = module.iam.lambda_role_arn
  bucket_name         = module.s3.bucket_name
  sns_topic_arn       = module.sns.topic_arn
  discord_webhook_url = var.discord_webhook_url
  telegram_bot_token  = var.telegram_bot_token
  telegram_chat_id    = var.telegram_chat_id
  lambda_source_file  = "${path.module}/lambda_src/lambda_function.py"
}

module "s3_notification" {
  source               = "./module/s3_notification"
  bucket_id            = module.s3.bucket_id
  lambda_function_arn  = module.lambda.lambda_function_arn
  lambda_function_name = module.lambda.lambda_function_name

  depends_on = [module.lambda]
}

module "ec2" {
  source = "./module/ec2"

  project_name          = var.project_name
  environment           = var.environment
  subnet_id             = module.vpc.public_subnet_id
  security_group_id     = module.security_group.ec2_security_group_id
  instance_profile_name = module.iam.ec2_instance_profile_name
  bucket_name           = module.s3.bucket_name
  instance_type         = var.instance_type
  key_name              = module.keypair.key_name
}

module "keypair" {
  source = "./module/keypair"

  project_name = var.project_name
  environment  = var.environment
}

module "route53" {
  source = "./module/route53"

  project_name      = var.project_name
  environment       = var.environment
  hosted_zone_name       = "sctp-sandbox.com"
  record_name       = "chatops-demo.sctp-sandbox.com"
  public_ip         = module.ec2.public_ip

}

module "sns_notifications" {
  source = "./module/sns"

  project_name   = var.project_name
  environment    = var.environment
  sns_topic_name = var.sns_topic_name
}