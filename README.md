# Terraform Basic 101

A **beginner-friendly** Terraform repository that demonstrates the complete
Terraform workflow on AWS — from bootstrapping state to deploying a working
web app — using **only modules from the Terraform Registry**. No hand-written
modules, one environment, one configuration (`infra/`), and every concept
explained in plain language.

This repo is the simplified sibling of
[`terraform-101`](https://github.com/offloadmemory/terraform-101) (the
enterprise multi-account, multi-environment demo). `terraform-101` shows what
Terraform looks like at scale; **this repo shows the same standards with the
least possible code** — ideal for a first hands-on session or workshop.

## What you will deploy

One small, fully working AWS stack. The whole environment lives in a **single
Terraform configuration** at `infra/`:

| Piece | What it is | Module used (Terraform Registry) |
|---|---|---|
| **network** | A VPC with public + private subnets and a NAT gateway | `terraform-aws-modules/vpc/aws` |
| **database** | A PostgreSQL RDS instance, locked to the VPC | `terraform-aws-modules/rds/aws` |
| **ecs** | A "hello world" container on Fargate behind a load balancer | `terraform-aws-modules/ecs/aws` + `terraform-aws-modules/alb/aws` |
| **bootstrap** | The S3 bucket that stores the stack's state (a separate one-time config) | `terraform-aws-modules/s3-bucket/aws` |

No custom resources are written anywhere — every piece of infrastructure
comes from a **public, versioned module** on the Terraform Registry.

## Repository layout

```
terraform-basic-101/
├── README.md                      ← you are here
├── Makefile                       # fmt / validate / plan / apply / destroy
├── scripts/                       # the same commands, as readable bash
├── docs/
│   ├── ARCHITECTURE.md            # how the architecture, state and config are organised
│   ├── CONCEPTS.md                # what state, providers, modules mean (beginner)
│   ├── SETUP.md                   # prerequisites, credentials, costs, teardown
│   ├── DEMO-SCRIPT.md             # a guided 15-minute narration
│   └── TROUBLESHOOTING.md         # the errors you WILL hit, and their fixes
├── .github/workflows/ci.yml       # fmt + validate + tflint on every PR
├── .pre-commit-config.yaml        # the same gates, run locally on commit
└── infra/                         # ══ THE TERRAFORM CODE ══
    ├── bootstrap/                 #   ⚠ creates the state bucket (run once, LOCAL state)
    ├── backend.tf                 # S3 remote state + locking for the whole stack
    ├── providers.tf               # provider "aws" (region + profile)
    ├── terraform.tf               # required_version + required_providers
    ├── variables.tf               # every input, in one file
    ├── terraform.tfvars           # every value, in one file
    ├── outputs.tf                 # every output, in one file
    ├── network.tf                 # VPC + subnets + NAT gateway (vpc module)
    ├── database.tf                # RDS PostgreSQL + security group (rds module)
    └── ecs.tf                     # ECS Fargate + ALB (ecs + alb modules)
```

**Two Terraform roots.** `infra/bootstrap/` is a small, separate configuration
that creates the state bucket (it keeps its own state *locally* — the
chicken-and-egg). `infra/` is **the whole environment in ONE configuration**:
one `terraform init`, one state file, and the resources split by concern into
`network.tf`, `database.tf`, `ecs.tf`. Because they share one state file, the
database and ECS reference the VPC directly (`module.vpc.*`) — no
cross-workspace state reads, no `terraform_remote_state`.

## Quick start (the whole demo in 2 steps)

```bash
# 0. Prerequisites: Terraform ≥ 1.11, AWS CLI, and an AWS profile named "dev"
#    (full details in docs/SETUP.md)

# 1. Create the state bucket (chicken-and-egg bootstrap — run once)
cd infra/bootstrap && terraform init && terraform apply

# 2. Create the WHOLE stack in one action (VPC + database + ECS)
cd .. && terraform init && terraform apply

# 3. Open the URL!
terraform output alb_dns_name
```

Or use the Makefile targets (`make apply`) — they run the same thing in the
right order.

> ⚠ **Costs.** This stack costs roughly **$60–80/month** while running
> (NAT gateway + RDS micro + ALB + Fargate). **Always `make destroy` after a
> demo.** See `docs/SETUP.md` → *Cost & teardown*.

## Apply order (dependency chain)

```
bootstrap → infra (network → database → ecs, all in one apply)
```

- `bootstrap` creates the S3 state bucket **before** anything can use it.
- `infra` runs as **one** `terraform apply`; Terraform orders the modules
  (VPC first, then the database and ECS that depend on it). It can only
  initialise after bootstrap, because its backend lives in the bucket.

## What this repo teaches

| Concept | Where it appears |
|---|---|
| Providers & `required_providers` | `infra/terraform.tf` + `providers.tf` |
| Variables, defaults, tfvars | `infra/variables.tf` + `terraform.tfvars` |
| Outputs (and `sensitive`) | `infra/outputs.tf` |
| Remote state & locking | `infra/backend.tf` |
| The bootstrap chicken-and-egg | `infra/bootstrap` |
| Modules from the Registry (no custom code!) | `network.tf`, `database.tf`, `ecs.tf` |
| Resources sharing one config (no `terraform_remote_state`) | `database.tf` + `ecs.tf` reference `module.vpc.*` directly |
| Quality gates: fmt, validate, tflint, CI | `.pre-commit-config.yaml`, `.github/workflows/ci.yml` |
| Why one configuration beats per-resource workspaces | `docs/ARCHITECTURE.md` |

Read `docs/CONCEPTS.md` for plain-English explanations of every one of these
before you start.

## Commands

```bash
make fmt        # terraform fmt --recursive (format all files)
make validate   # offline: fmt + init -backend=false + validate both configs
make plan       # plan both configurations (needs credentials + bootstrap done)
make apply      # apply bootstrap, then the whole stack (needs credentials)
make destroy    # teardown the stack, then bootstrap (needs credentials)
```

Quality gates:

```bash
pre-commit install          # one-time — runs fmt/validate/tflint on every commit
pre-commit run --all-files  # or run them all right now
```

CI runs the same checks on every pull request (`.github/workflows/ci.yml`).

## Docs index

- `docs/CONCEPTS.md` — the 10 ideas you need before touching Terraform.
- `docs/ARCHITECTURE.md` — repo layout, state, and the configuration model.
- `docs/SETUP.md` — prerequisites, AWS profiles, bootstrap, cost, teardown.
- `docs/DEMO-SCRIPT.md` — a narrated 15-minute demo script.
- `docs/TROUBLESHOOTING.md` — the mistakes beginners make, with fixes.

## License

MIT — use it, teach with it, fork it.
