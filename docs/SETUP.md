# Setup

Everything you need to run this repository on your machine — prerequisites,
AWS credentials, the one-time bootstrap, costs, and teardown.

## Prerequisites

| Tool | Version | Why |
|---|---|---|
| Terraform | **1.11+** (verified with 1.13.x) | S3-native state locking needs ≥ 1.11 |
| AWS CLI | v2 | To authenticate with AWS |
| An AWS account | any | The demo runs in `us-east-1` |
| Optional | | `pre-commit` + `tflint` for the local quality gates |

Install Terraform on macOS (also available on Windows/Linux):

```bash
brew install terraform
terraform version   # should print v1.11 or newer
```

## AWS credentials

Create a named profile called `dev` in `~/.aws/credentials`:

```ini
[dev]
aws_access_key_id = AKIA...
aws_secret_access_key = ...
```

> If you already use AWS SSO (`aws sso login`), your profile instead lives
> in `~/.aws/config` — either way, the name must be `dev`, and the
> `profile = "dev"` lines in this repo will pick it up.

The `dev` profile needs permission to create (and later delete):

- **S3** — the state bucket (bootstrap)
- **EC2 / VPC** — VPC, subnets, NAT gateway, security groups
- **RDS** — the PostgreSQL instance
- **ECS / ECR / CloudWatch / ELB / IAM** — the cluster, Fargate service,
  load balancer, log group, and the IAM roles the modules create

For a demo, an AdministratorAccess policy is fine. Least-privilege
instructions are out of scope for a 101 repo — that's an enterprise topic.

> ⚠ The profile name `dev` is used by *every* workspace in this repo
> (`providers.tf` and `backend.tf`). If your profile is named differently,
> change `profile = "dev"` in every `providers.tf` and `backend.tf`.

## One-time bootstrap

The state bucket must exist before anything else can run:

```bash
cd environments/bootstrap
terraform init
terraform apply
```

This creates `terraform-basic-101-tfstate` — versioned, encrypted, private.
Bucket names are **globally unique**; if it's taken you'll see
`BucketAlreadyExists`. Fix by changing `state_bucket_name` in
`bootstrap/terraform.tfvars` **and** the bucket in every `backend.tf`
(network, database, ecs).

## Deploy (the demo)

```bash
cd environments/dev/network  && terraform init && terraform apply
cd environments/dev/database && terraform init && terraform apply
cd environments/dev/ecs      && terraform init && terraform apply

cd environments/dev/ecs
terraform output alb_dns_name   # copy this URL into a browser
```

Or with the Makefile (same order, less typing):

```bash
make apply
```

The ECS service pulls a small "hello world" container image from Docker Hub
(`kartikmanimuthu/hello-101`). If the image name is ever removed, change
`container_image` in `dev/ecs/terraform.tfvars` to any public image that
serves HTTP on port 80.

## Costs

This stack, while running, is roughly **$60–80/month**:

| Resource | ~$/month |
|---|---|
| NAT gateway (1) | ~$34 |
| RDS PostgreSQL micro (20 GB) | ~$13 |
| ALB | ~$16 |
| Fargate task (256/512) | ~$4 |
| (state bucket + data transfer) | negligible |

That is the price of a *long-running* demo. **Destroy the stack when you're
done — every hour it stays up costs money.**

## Teardown

```bash
make destroy
# optional: also remove the state bucket
./scripts/destroy-all.sh --include-bootstrap
```

Or manually, in reverse dependency order:

```bash
cd environments/dev/ecs      && terraform destroy -auto-approve
cd environments/dev/database && terraform destroy -auto-approve
cd environments/dev/network  && terraform destroy -auto-approve
```

Notes:

- `database` is created with `skip_final_snapshot = true` and
  `deletion_protection = false`, so `destroy` just works — no snapshot
  prompt, no locked instance.
- `bootstrap` is **not** destroyed by `make destroy` by default: removing
  the bucket would delete your state history. Only pass `--include-bootstrap`
  when you're sure.

## Local quality gates (optional but recommended)

```bash
pip install pre-commit
pre-commit install          # runs fmt/validate/tflint on every commit
pre-commit run --all-files  # or run them all right now
```

CI runs the same three checks on every pull request
(`.github/workflows/ci.yml`) — no extra setup needed.
