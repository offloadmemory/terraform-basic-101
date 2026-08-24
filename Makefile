.PHONY: fmt validate plan apply destroy

## fmt: format all Terraform files in the repo
fmt:
	terraform fmt --recursive

## validate: offline check — fmt + init -backend=false + validate on every workspace
validate:
	@./scripts/validate-all.sh

## plan: real init + plan on every workspace (needs credentials)
plan:
	@./scripts/plan-all.sh

## apply: apply every workspace in dependency order (needs credentials)
apply:
	@./scripts/apply-all.sh

## destroy: teardown every workspace in reverse order (needs credentials)
destroy:
	@./scripts/destroy-all.sh
