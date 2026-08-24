#!/usr/bin/env bash
# Apply both configurations in dependency order: bootstrap -> infra.
# Needs AWS credentials.
set -euo pipefail

echo "==> apply infra/bootstrap"
(cd infra/bootstrap && terraform init && terraform apply -auto-approve)

echo "==> apply infra"
(cd infra && terraform init && terraform apply -auto-approve)

echo "All configurations applied."
