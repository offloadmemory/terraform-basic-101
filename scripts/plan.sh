#!/usr/bin/env bash
# Plan both configurations. Needs AWS credentials and the state bucket
# (infra/bootstrap) to already exist.
set -euo pipefail

# bootstrap is planned on its own: it uses local state and has no backend.
echo "==> plan infra/bootstrap"
(cd infra/bootstrap && terraform init && terraform plan)

echo "==> plan infra"
(cd infra && terraform init && terraform plan)

echo "All configurations planned."
