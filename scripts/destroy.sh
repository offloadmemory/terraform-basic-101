#!/usr/bin/env bash
# Destroy the stack in REVERSE dependency order: infra -> infra/bootstrap.
# bootstrap (the state bucket) is destroyed last, and only if you pass
# --include-bootstrap. Needs AWS credentials.
set -euo pipefail

echo "==> destroy infra"
(cd infra && terraform init && terraform destroy -auto-approve)

if [[ "${1:-}" == "--include-bootstrap" ]]; then
  echo "==> destroy infra/bootstrap"
  (cd infra/bootstrap && terraform init && terraform destroy -auto-approve)
else
  echo "Skipping infra/bootstrap (pass --include-bootstrap to remove the state bucket)."
fi

echo "Teardown complete."
