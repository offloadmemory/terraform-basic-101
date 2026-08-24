#!/usr/bin/env bash
# Destroy every workspace in REVERSE dependency order: ecs -> database -> network.
# bootstrap (the state bucket) is destroyed last, and only if you pass --include-bootstrap.
# Needs AWS credentials.
set -euo pipefail

for dir in environments/dev/ecs environments/dev/database environments/dev/network; do
  echo "==> destroy ${dir}"
  (cd "${dir}" && terraform init && terraform destroy -auto-approve)
done

if [[ "${1:-}" == "--include-bootstrap" ]]; then
  echo "==> destroy environments/bootstrap"
  (cd environments/bootstrap && terraform init && terraform destroy -auto-approve)
else
  echo "Skipping environments/bootstrap (pass --include-bootstrap to remove the state bucket)."
fi

echo "Teardown complete."
