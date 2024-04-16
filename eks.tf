# Creating EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = "AWS-EKS"
  role_arn =  aws_iam_role.master.arn

  vpc_config {
    subnet_ids = module.vpc.public_subnets
    endpoint_private_access = true
    endpoint_public_access  = true
  }
}

# Using Data Source to get all Avalablility Zones in Region
data "aws_availability_zones" "available_zones" {}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Creating kubectl server
resource "aws_instance" "kubectl-server" {
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = aws_key_pair.task_5-0.key_name
  instance_type               = "t2.xlarge"
  associate_public_ip_address = true
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.eks_security_group.id]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.public_ip
    private_key = tls_private_key.ssh_key.private_key_openssh
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "echo '${tls_private_key.ssh_key.private_key_openssh}' >> ~/task_5_0.pem",
      "chmod 400 ~/task_5_0.pem",
    ]
  }

  tags = {
    Name = "task-5-0-kubectl"
  }
}

# Creating Worker Node Group
resource "aws_eks_node_group" "node-grp" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "Worker-Node-Group"
  node_role_arn   = aws_iam_role.worker.arn
  subnet_ids      = [module.vpc.private_subnets[0]]
  capacity_type   = "ON_DEMAND"
  disk_size       = 20
  instance_types = ["t2.xlarge"]

  remote_access {
    ec2_ssh_key               = aws_key_pair.task_5-0.key_name
    source_security_group_ids = [aws_security_group.eks_security_group.id]
  }

  tags = {
    Name = "task-5-0-worker-node-group"
  }

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }
}