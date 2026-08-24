# Demo script — ~15 minutes, zero slides

A guided narration for a live, hands-on demo of this repository. Perfect for
a workshop, a team brown-bag, or your own first end-to-end run. Read it
before you start; the beats are ordered so each concept lands on top of the
previous one.

> **Before you begin:** `docs/SETUP.md` prerequisites must be done — Terraform
> installed, AWS profile `dev` configured, and **no** prior bootstrap (or a
> clean teardown).

---

## Beat 0 — The shape (2 min)

```
tree infra
```

Walk the tree: `bootstrap/` + the single configuration (`network.tf`,
`database.tf`, `ecs.tf`, plus `backend.tf`, `providers.tf`, `variables.tf`,
`terraform.tfvars`, `outputs.tf`).

**Say:** "One environment, one configuration, no modules we wrote ourselves.
Everything the app needs — VPC, database, ECS — lives in ONE Terraform root,
split by concern into three files. One `init`, one state file, one apply.
This is a simpler version of the layout an enterprise uses."

---

## Beat 1 — Bootstrap chicken-and-egg (3 min)

```bash
cd infra/bootstrap
terraform init
terraform apply
```

Open `backend.tf`… there is **no `backend.tf`** in bootstrap.

**Ask:** "Why does this configuration not point at the S3 bucket like
`infra/` does?" **Answer:** "It *creates* the bucket. Terraform can't store
its state in a bucket that doesn't exist yet — so this one keeps state
locally, creates the bucket, and the main configuration uses it. This is the
chicken-and-egg of state, and it's the single most important idea in this
demo."

Also point at `main.tf`: one module call, `terraform-aws-modules/s3-bucket/aws`
from the **Terraform Registry**. "No custom code — the bucket, its
versioning, encryption, and public-access block all come from a vetted,
versioned module."

## Beat 2 — The whole stack in one apply (7 min)

```bash
cd ..
terraform init
terraform apply
```

While it runs (a NAT gateway takes a couple of minutes), open the files:

1. `network.tf` — the VPC is **six lines of input** to the `vpc` registry
   module. Ask: "How many resources does the module create?" Answer: dozens
   (VPC, subnets, IGW, NAT, route tables). "That's the point of modules."
2. `backend.tf` — **this** is the remote state pointer: bucket, key,
   locking. "One state file for the whole stack. This file is why you can
   run Terraform from any laptop and pick up exactly where you left off."
3. `database.tf` — point at `module.vpc.private_subnets`:
   **Say:** "The database needs subnet IDs and the VPC ID from the network —
   and they're in the *same* configuration, so it references them directly.
   In a multi-workspace repo you'd have to read another state file with
   `terraform_remote_state`; here, one state, direct references, and
   Terraform orders the apply itself. Resources create things, references
   share things."
4. `terraform.tfvars` — "these are the *only* values you'd change to make a
   second environment."
5. `ecs.tf` — three module calls:
   - **cluster** — a Fargate-ready ECS cluster (plus its CloudWatch log group).
   - **alb** — the load balancer in the *public* subnets, HTTP :80 → target
     group `ecs`.
   - **service** — the container in the *private* subnets, attached to that
     target group. "The service security group only allows traffic from the
     ALB — the app is reachable only through the load balancer."

Also point at:

- `manage_master_user_password = true` — "the database password is generated
  and stored by AWS Secrets Manager. No password in the code, none in state."
- outputs marked `sensitive` — "endpoints are credentials-adjacent; Terraform
  hides them from `terraform output` unless you ask."

When it finishes, show the outputs:

```bash
terraform output          # db_name is visible, endpoint is hidden
terraform output alb_dns_name
terraform output -json    # (or get everything programmatically)
```

Open the URL in a browser — you get a "hello" page. **That is your entire
stack, live, built from four registry modules in one apply.**

## Beat 3 — teardown discipline (2 min)

```bash
cd .. && make destroy
```

**Say:** "Everything we created is declared in code, so everything can be
destroyed from code — no orphaned resources left clicking around the
console. And here's the magic: the next `make apply` recreates the entire
stack from these files. That's infrastructure as code."

Optionally re-run `make apply` to show the full cycle.

---

## Recap board

| You saw | Concept |
|---|---|
| No `backend.tf` in `infra/bootstrap` | The state chicken-and-egg |
| `database.tf` uses `module.vpc.*` | One configuration, direct references — no `terraform_remote_state` |
| `module "…"` with a registry source | Modules = reusable bundles of resources |
| `sensitive = true` | Output hygiene |
| `make destroy` | IaC means the whole stack is disposable |

---

## If something fails

Check `docs/TROUBLESHOOTING.md` — it covers the exact errors beginners hit
(`BucketAlreadyExists`, state-lock, `plan`/`validate` needing init,
applying `infra` before bootstrap, image pull, destroy order).
