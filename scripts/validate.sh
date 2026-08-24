#!/usr/bin/env bash
# Validate every Terraform configuration WITHOUT touching the S3 backend or
# needing credentials. Runs: terraform fmt + init -backend=false + validate.
#
# Two configurations:
#   infra/bootstrap — the state bucket (local state, no backend)
#   infra           — the whole stack (backend disabled for the offline check)
set -euo pipefail

for dir in infra/bootstrap infra; do
  echo "==> validate ${dir}"
  (cd "${dir}" && terraform fmt --recursive && terraform init -backend=false && terraform validate)
done

echo "All configurations validated."
