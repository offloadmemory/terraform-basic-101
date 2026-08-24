# Terraform Basic 101

A **beginner-friendly** Terraform repository that demonstrates the complete
Terraform workflow on AWS — from bootstrapping state to deploying a working
web app — using **only modules from the Terraform Registry**. No hand-written
modules, one environment, four workspaces, and every concept explained in
plain language.

This repo is the simplified sibling of
[`terraform-101`](https://github.com/offloadmemory/terraform-101) (the
enterprise multi-account, multi-environment demo). `terraform-101` shows what
Terraform looks like at scale; **this repo shows the same standards with the
least possible code** — ideal for a first hands-on session or workshop.

## What you will deploy

One small, fully working AWS stack in the `dev` environment:

| Piece | What it is | Module used (Terraform Registry) |
|---|---|---|
| **network** | A VPC with public + private subnets and a NAT gateway | `terraform-aws-modules/vpc/aws` |
| **database** | A PostgreSQL RDS instance, locked to the VPC | `terraform-aws-modules/rds/aws` |
| **ecs** | A "hello world" container on Fargate behind a load balancer | `terraform-aws-modules/ecs/aws` + `terraform-aws-modules/alb/aws` |
| **bootstrap** | The S3 bucket that stores everyone's state | `terraform-aws-modules/s3-bucket/aws` |

No custom modules are written anywhere — every piece of infrastructure comes
from a **public, versioned module** on the Terraform Registry.

## Repository layout

```
terraform-basic-101/
├── README.md                      ← you are here
├── Makefile                       # fmt / validate / plan / apply / destroy
├── scripts/                       # the same commands, as readable bash
├── docs/
│   ├── ARCHITECTURE.md            # how the repo, state and workspaces are organised
│   ├── CONCEPTS.md                # what state, providers, modules mean (beginner)
│   ├── SETUP.md                   # prerequisites, credentials, costs, teardown
│   ├── DEMO-SCRIPT.md             # a guided 15-minute narration
│   └── TROUBLESHOOTING.md         # the errors you WILL hit, and their fixes
├── .github/workflows/ci.yml       # fmt + validate + tflint on every PR
├── .pre-commit-config.yaml        # the same gates, run locally on commit
└── environments/                  # ══ one folder per workspace ══
    ├── bootstrap/                 #   ⚠ creates the state bucket (run once)
    └── dev/                       #   the whole dev environment
        ├── network/               #     its own state file
        ├── database/              #     its own state file
        └── ecs/                   #     its own state file
```

Each workspace folder is a complete, independent Terraform configuration with
its own state file — the standard HashiCorp layout. Every file in a workspace
follows the HashiCorp conventions: `providers.tf`, `main.tf`, `variables.tf`,
`outputs.tf`, `terraform.tf`, `backend.tf`, `terraform.tfvars`.

## Quick start (the whole demo in 4 commands)

```bash
# 0. Prerequisites: Terraform ≥ 1.11, AWS CLI, and an AWS profile named "dev"
#    (full details in docs/SETUP.md)

# 1. Create the state bucket (chicken-and-egg bootstrap — run once)
cd environments/bootstrap && terraform init && terraform apply

# 2. Create the network (VPC + subnets + NAT)
cd ../dev/network && terraform init && terraform apply

# 3. Create the database (reads the network's outputs automatically)
cd ../database && terraform init && terraform apply

# 4. Create the app (cluster + load balancer + Fargate service)
cd ../ecs && terraform init && terraform apply

# 5. Open the URL!
terraform output alb_dns_name
```

Or use the Makefile targets (`make apply`) — they run the same thing in the
right order.

> ⚠ **Costs.** This stack costs roughly **$60–80/month** while running
> (NAT gateway + RDS micro + ALB + Fargate). **Always `make destroy` after a
> demo.** See `docs/SETUP.md` → *Cost & teardown*.

## Apply order (dependency chain)

```
bootstrap → network → database → ecs
```

- `bootstrap` creates the S3 state bucket **before** anything can use it.
- `network` creates the VPC everything else needs.
- `database` and `ecs` **read the network's outputs** from its state file
  (`data "terraform_remote_state"`), so they must run *after* network.

## What this repo teaches

| Concept | Where it appears |
|---|---|
| Providers & `required_providers` | every `terraform.tf` |
| Variables, defaults, tfvars | every `variables.tf` + `terraform.tfvars` |
| Outputs (and `sensitive`) | every `outputs.tf` |
| Remote state & locking | `backend.tf` in network/database/ecs |
| The bootstrap chicken-and-egg | `environments/bootstrap` |
| Modules from the Registry (no custom code!) | every `main.tf` |
| `terraform_remote_state` — sharing values between workspaces | `main.tf` in database + ecs |
| Resources vs data sources | `main.tf` (module calls) vs `data "terraform_remote_state"` |
| Quality gates: fmt, validate, tflint, CI | `.pre-commit-config.yaml`, `.github/workflows/ci.yml` |
| Why one folder per environment beats `terraform workspace` | `docs/ARCHITECTURE.md` |

Read `docs/CONCEPTS.md` for plain-English explanations of every one of these
before you start.

## Commands

```bash
make fmt        # terraform fmt --recursive (format all files)
make validate   # offline: fmt + init -backend=false + validate every workspace
make plan       # plan every workspace (needs credentials + bootstrap done)
make apply      # apply every workspace in dependency order (needs credentials)
make destroy    # teardown every workspace in reverse order (needs credentials)
```

Quality gates:

```bash
pre-commit install          # one-time — runs fmt/validate/tflint on every commit
pre-commit run --all-files  # or run them all right now
```

CI runs the same checks on every pull request (`.github/workflows/ci.yml`).

## Docs index

- `docs/CONCEPTS.md` — the 10 ideas you need before touching Terraform.
- `docs/ARCHITECTURE.md` — repo layout, state, and the environment model.
- `docs/SETUP.md` — prerequisites, AWS profiles, bootstrap, cost, teardown.
- `docs/DEMO-SCRIPT.md` — a narrated 15-minute demo script.
- `docs/TROUBLESHOOTING.md` — the mistakes beginners make, with fixes.

## License

MIT — use it, teach with it, fork it.
