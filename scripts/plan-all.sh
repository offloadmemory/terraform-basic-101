#!/usr/bin/env bash
# Plan every workspace. Needs AWS credentials and the state bucket (bootstrap) to exist.
set -euo pipefail

# bootstrap is planned on its own: it uses local state and has no backend.
echo "==> plan environments/bootstrap"
(cd environments/bootstrap && terraform init && terraform plan)

for dir in environments/dev/network environments/dev/database environments/dev/ecs; do
  echo "==> plan ${dir}"
  (cd "${dir}" && terraform init && terraform plan)
done

echo "All workspaces planned."
