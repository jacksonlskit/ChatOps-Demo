output "key_name" {
  value = aws_key_pair.chatdemo_keypair.key_name
}

output "key_file" {
  value = local_file.chatdemo_private_key.filename
}