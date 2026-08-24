#!/usr/bin/env bash
# Apply every workspace in dependency order: bootstrap -> network -> database -> ecs.
# Needs AWS credentials.
set -euo pipefail

echo "==> apply environments/bootstrap"
(cd environments/bootstrap && terraform init && terraform apply -auto-approve)

for dir in environments/dev/network environments/dev/database environments/dev/ecs; do
  echo "==> apply ${dir}"
  (cd "${dir}" && terraform init && terraform apply -auto-approve)
done

echo "All workspaces applied."
