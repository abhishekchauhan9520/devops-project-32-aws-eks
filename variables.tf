variable "region" {
  description = "AWS region for the EKS platform."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name used in resource naming and tags."
  type        = string
  default     = "platform"
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
  default     = "platform-eks"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes minor version."
  type        = string
  default     = "1.35"

  validation {
    condition     = can(regex("^1\\.(3[4-6])$", var.kubernetes_version))
    error_message = "Use a currently supported EKS minor version such as 1.34, 1.35, or 1.36."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the EKS VPC."
  type        = string
  default     = "10.40.0.0/16"
}

variable "admin_role_arn" {
  description = "IAM role ARN for cluster administration via EKS Access Entries."
  type        = string

  validation {
    condition     = startswith(var.admin_role_arn, "arn:")
    error_message = "admin_role_arn must be a valid IAM role ARN."
  }
}

variable "api_public_access_cidrs" {
  description = "CIDR ranges allowed to reach the EKS public Kubernetes API endpoint. Keep this narrow."
  type        = list(string)

  validation {
    condition     = length(var.api_public_access_cidrs) > 0 && alltrue([for cidr in var.api_public_access_cidrs : can(cidrhost(cidr, 0))])
    error_message = "Provide at least one valid CIDR for Kubernetes API access."
  }
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed node group."
  type        = list(string)
  default     = ["m6i.large"]
}

variable "node_min_size" {
  description = "Minimum size of the managed node group."
  type        = number
  default     = 2
}

variable "node_desired_size" {
  description = "Desired size of the managed node group."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum size of the managed node group."
  type        = number
  default     = 4
}
