#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

: "${TFVARS_FILE:=$ROOT_DIR/terraform.tfvars}"
[[ -f "$TFVARS_FILE" ]] || { echo "Missing $TFVARS_FILE." >&2; exit 64; }

if [[ "${CONFIRM_DESTROY:-}" != "DELETE-EKS-PLATFORM" ]]; then
  echo "Refusing destroy. Set CONFIRM_DESTROY=DELETE-EKS-PLATFORM to continue." >&2
  exit 64
fi

terraform init -upgrade=false
terraform plan -destroy -var-file="$TFVARS_FILE"

if [[ "${EXECUTE_DESTROY:-false}" != "true" ]]; then
  echo "Destroy plan only. Set EXECUTE_DESTROY=true after review." >&2
  exit 0
fi

terraform destroy -var-file="$TFVARS_FILE"
