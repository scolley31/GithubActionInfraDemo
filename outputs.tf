# IAM Wokrer Node Instance Profile
output "instance_profile" {
  value = aws_iam_instance_profile.worker.name
}

# IAM Role Master's ARN
output "master_arn" {
  value = aws_iam_role.master.arn
}

# IAM Role Worker's ARN
output "worker_arn" {
  value = aws_iam_role.worker.arn
}

output "region" {
  value = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = aws_eks_cluster.eks.name
}