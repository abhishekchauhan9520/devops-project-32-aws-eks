output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS Kubernetes API endpoint."
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "cluster_arn" {
  description = "EKS cluster ARN."
  value       = module.eks.cluster_arn
}

output "cluster_security_group_id" {
  description = "EKS control-plane security group ID."
  value       = module.eks.cluster_primary_security_group_id
}

output "node_group_iam_role_arn" {
  description = "Managed node group IAM role ARN."
  value       = module.eks.eks_managed_node_groups["system"].iam_role_arn
}

output "ebs_csi_role_arn" {
  description = "IAM role used by the EBS CSI driver through EKS Pod Identity."
  value       = aws_iam_role.ebs_csi.arn
}

output "kubectl_config_command" {
  description = "AWS CLI command to configure local kubectl access."
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}
