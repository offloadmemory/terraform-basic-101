.PHONY: fmt validate plan apply destroy

## fmt: format all Terraform files in the repo
fmt:
	terraform fmt --recursive

## validate: offline check — fmt + init -backend=false + validate on every configuration
validate:
	@./scripts/validate.sh

## plan: real init + plan on both configurations (needs credentials)
plan:
	@./scripts/plan.sh

## apply: apply both configurations in dependency order (needs credentials)
apply:
	@./scripts/apply.sh

## destroy: teardown the stack in reverse order (needs credentials)
destroy:
	@./scripts/destroy.sh
