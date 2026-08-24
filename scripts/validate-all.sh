#!/usr/bin/env bash
# Validate every workspace WITHOUT touching the S3 backend or needing credentials.
# Runs: terraform fmt + init -backend=false + validate
set -euo pipefail

for dir in environments/bootstrap environments/dev/network environments/dev/database environments/dev/ecs; do
  echo "==> validate ${dir}"
  (cd "${dir}" && terraform fmt --recursive && terraform init -backend=false && terraform validate)
done

echo "All workspaces validated."
