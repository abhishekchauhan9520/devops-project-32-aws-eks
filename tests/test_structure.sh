#!/usr/bin/env bash
set -euo pipefail

fail() { echo "FAIL: $1" >&2; exit 1; }

for file in versions.tf variables.tf main.tf outputs.tf terraform.tfvars.example .github/workflows/terraform.yml README.md .gitignore LICENSE; do
  [[ -f "$file" ]] || fail "missing $file"
done

for script in scripts/plan.sh scripts/apply.sh scripts/destroy.sh; do
  [[ -f "$script" ]] || fail "missing $script"
  bash -n "$script"
done

grep -q 'authentication_mode[[:space:]]*= "API"' main.tf || fail "EKS access entries authentication mode not enabled"
grep -q 'enable_cluster_creator_admin_permissions[[:space:]]*= false' main.tf || fail "cluster creator admin permissions must remain disabled"
grep -q 'aws-ebs-csi-driver' main.tf || fail "EBS CSI addon missing"
grep -q 'eks-pod-identity-agent' main.tf || fail "EKS Pod Identity agent missing"
grep -q 'http_tokens[[:space:]]*= "required"' main.tf || fail "IMDSv2 is not required"
grep -q 'endpoint_private_access[[:space:]]*= true' main.tf || fail "private API endpoint not enabled"
grep -q 'enable_nat_gateway[[:space:]]*= true' main.tf || fail "NAT gateway configuration missing"

if grep -RqsE 'AKIA[0-9A-Z]{16}|aws_secret_access_key[[:space:]]*=' --exclude-dir=.git .; then
  fail "possible static AWS credential detected"
fi

if grep -RqsE 'terraform apply' .github/workflows; then
  fail "CI must not auto-apply EKS infrastructure"
fi

printf 'Project 32 structure/security checks passed.\n'
