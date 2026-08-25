output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
}

output "security_group_id" {
  value = module.security_group.ec2_security_group_id
}

output "bucket_name" {
  value = module.s3.bucket_name
}

output "s3_bucket_arn" {
  value = module.s3.bucket_arn
}

output "sns_topic_arn" {
  value = module.sns.topic_arn
}

#---------------------------------------------------------------
#phase 2

output "ec2_public_ip" {
  value = module.ec2.public_ip

}

output "ec2_public_dns" {
  value = module.ec2.public_dns

}

output "lambda_function_name" {
  value = module.lambda.lambda_function_name

}

output "key_pair_name" {
  value = module.keypair.key_name

}

output "private_key_file" {
  value = module.keypair.key_file

}



output "chatops_demo_url" {
  value = "http://${module.route53.fqdn}"
}