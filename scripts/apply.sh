#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

: "${TFVARS_FILE:=$ROOT_DIR/terraform.tfvars}"

[[ -f "$TFVARS_FILE" ]] || {
  echo "Missing $TFVARS_FILE." >&2
  exit 64
}

terraform init -upgrade=false
terraform fmt -check -recursive
terraform validate
terraform plan -var-file="$TFVARS_FILE" -out=tfplan

echo "Plan created at tfplan. Review it before applying: terraform apply tfplan"
