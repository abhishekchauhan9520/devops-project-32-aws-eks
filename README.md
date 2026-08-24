# Project 32 — Production AWS EKS Platform

A production-oriented Amazon EKS platform built with Terraform. This project focuses on managed Kubernetes operations, secure cluster access, private worker nodes, encrypted control-plane secrets, managed add-ons, and workload IAM through EKS Pod Identity.

## Architecture

```text
                          AWS Region
                              |
                 +------------+------------+
                 |                         |
             Public subnets             Private subnets
                 |                         |
          NAT gateways / egress       EKS control-plane ENIs
                                           |
                                      Amazon EKS 1.35
                                           |
                                  Managed node group (AL2023)
                                           |
                          +----------------+----------------+
                          |                |                |
                       CoreDNS         VPC CNI      Pod Identity Agent
                          |                                 |
                      Kubernetes                         AWS IAM role
                          |
                    EBS CSI driver
                          |
                     EBS volumes
```

## Production controls

- EKS API authentication uses EKS Access Entries instead of the legacy `aws-auth` ConfigMap.
- Cluster creator is not automatically granted administrator access.
- Kubernetes API public access is explicitly CIDR-restricted; private access is enabled.
- Kubernetes secrets use a customer-managed KMS key created by the EKS module.
- EKS control-plane logs are enabled for API, audit, authenticator, controller-manager, and scheduler streams.
- Managed node groups use Amazon Linux 2023 and IMDSv2 with hop limit 1.
- Nodes run in private subnets behind NAT gateways.
- EBS CSI uses EKS Pod Identity with a dedicated IAM role.
- The GitHub Actions workflow validates only; it never applies infrastructure.
- The destroy script requires explicit confirmation and defaults to plan-only behavior.

## Current versions

At the time this project was built, the AWS provider is pinned to `6.60.0`, the Terraform EKS module to `21.24.2`, and the VPC module to `6.6.1`. The cluster defaults to Kubernetes `1.35`, which is currently in Amazon EKS standard support. These versions should be reviewed before a future upgrade. The EKS module currently exposes Access Entries and Pod Identity integrations, and AWS recommends Access Entries for modern cluster access and EKS Pod Identity for workload IAM. [AWS EKS access management](https://docs.aws.amazon.com/eks/latest/best-practices/cluster-access-management.html) · [EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html) · [EKS module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) · [VPC module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)

## Prerequisites

- AWS account with permissions to create EKS, VPC, IAM, KMS, EC2, CloudWatch, and related resources
- Terraform 1.9+
- AWS CLI
- `kubectl`
- An IAM role for cluster administration

## Deploy

Copy the example variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Set:

- `admin_role_arn` to the IAM role that will administer the cluster through an EKS Access Entry
- `api_public_access_cidrs` to your trusted public IP ranges (avoid `0.0.0.0/0`)

Then:

```bash
terraform init
terraform fmt -check -recursive
terraform validate
./scripts/plan.sh
```

Review the plan. To create a saved plan for manual approval:

```bash
./scripts/apply.sh
terraform apply tfplan
```

Configure `kubectl` using the output command:

```bash
aws eks update-kubeconfig --region <region> --name <cluster>
```

## Destroy

The destroy helper is deliberately guarded:

```bash
CONFIRM_DESTROY=DELETE-EKS-PLATFORM ./scripts/destroy.sh
```

That produces a destroy plan only. To actually destroy the platform, review the plan and then run:

```bash
CONFIRM_DESTROY=DELETE-EKS-PLATFORM EXECUTE_DESTROY=true ./scripts/destroy.sh
```

## CI

GitHub Actions runs:

1. `terraform fmt -check -recursive`
2. `terraform init -backend=false`
3. `terraform validate`
4. repository security assertions
5. static module/version checks

No AWS resources are applied by CI.

## Notes

This project intentionally does not create workloads on the cluster. Projects later in the portfolio can consume this EKS platform for GitOps, observability, security, autoscaling, and AI workloads.

Do not commit `terraform.tfvars`, Terraform state, kubeconfig files, credentials, or AWS access keys.
