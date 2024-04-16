resource "tls_private_key" "ssh_key" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "task_5-0" {
  key_name   = "task_5_0"
  public_key = trimspace(tls_private_key.ssh_key.public_key_openssh)
}

resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_openssh
  filename = "task_5_0.pem"
  provisioner "local-exec" {
    command = "chmod 400 task_5_0.pem"
  }
}
