resource "tls_private_key" "chatdemo_keypair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "chatdemo_keypair" {
  key_name   = "${var.project_name}-${var.environment}-keypair"
  public_key = tls_private_key.chatdemo_keypair.public_key_openssh
}

resource "local_file" "chatdemo_private_key" {
  content         = tls_private_key.chatdemo_keypair.private_key_pem
  filename        = "${path.root}/${var.project_name}-${var.environment}-key.pem"
  file_permission = "0400"
}