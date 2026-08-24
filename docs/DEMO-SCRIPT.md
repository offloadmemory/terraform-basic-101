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
tree environments
```

Walk the tree: `bootstrap` + `dev/{network,database,ecs}`.

**Say:** "One environment, four workspaces, no modules we wrote ourselves.
Every folder is an independent Terraform config with its own state file.
This is the same layout an enterprise uses — just with one environment
instead of ten."

---

## Beat 1 — Bootstrap chicken-and-egg (3 min)

```bash
cd environments/bootstrap
terraform init
terraform apply
```

Open `backend.tf`… there is **no `backend.tf`** in bootstrap.

**Ask:** "Why does this workspace not point at the S3 bucket like the
others?" **Answer:** "It *creates* the bucket. Terraform can't store its
state in a bucket that doesn't exist yet — so this one keeps state locally,
creates the bucket, and everything else uses it. This is the chicken-and-egg
of state, and it's the single most important idea in this demo."

Also point at `main.tf`: one module call, `terraform-aws-modules/s3-bucket/aws`
from the **Terraform Registry**. "No custom code — the bucket, its
versioning, encryption, and public-access block all come from a vetted,
versioned module."

---

## Beat 2 — network (5 min)

```bash
cd ../dev/network
terraform init
terraform apply
```

While it runs (a NAT gateway takes a couple of minutes), walk through:

1. `main.tf` — the VPC is **six lines of input** to the `vpc` registry
   module. Ask: "How many resources does the module create?" Answer: dozens
   (VPC, subnets, IGW, NAT, route tables). "That's the point of modules."
2. `providers.tf` + `terraform.tf` — the provider and its version pin.
3. `terraform.tfvars` — "these are the *only* things you'd change to make a
   second environment."
4. `backend.tf` — **this** is the remote state pointer: bucket, key,
   locking. "This file is why you can run Terraform from any laptop and
   pick up exactly where you left off."

When it finishes, show the outputs:

```bash
terraform output vpc_id
```

## Beat 3 — database reads the network (4 min)

```bash
cd ../database
terraform init
terraform apply
```

Open `main.tf` and point at `data "terraform_remote_state" "network"`:

**Say:** "The database needs subnet IDs and a security group from the
network — but they live in a *different workspace*, with a *different state
file*. A data source reads that state at run time. This is how Terraform
shares values between workspaces: resources create things, data sources read
things."

Also point at:

- `manage_master_user_password = true` — "the database password is generated
  and stored by AWS Secrets Manager. No password in the code, none in state."
- outputs marked `sensitive` — "endpoints are credentials-adjacent; Terraform
  hides them from `terraform output` unless you ask."

```bash
terraform output          # db_name is visible, endpoint is hidden
terraform output -json    # (or get them programmatically)
```

## Beat 4 — ecs (5 min)

```bash
cd ../ecs
terraform init
terraform apply
```

Three module calls in this workspace:

1. **cluster** — a Fargate-ready ECS cluster (plus its CloudWatch log group).
2. **alb** — the load balancer in the *public* subnets, HTTP :80 → target
   group `ecs`.
3. **service** — the container in the *private* subnets, attached to that
   target group. "The service security group only allows traffic from the
   ALB — the app is reachable only through the load balancer."

When it finishes:

```bash
terraform output alb_dns_name
```

Open the URL in a browser — you get a "hello" page. **That is your entire
stack, live, built from four registry modules.**

## Beat 5 — teardown discipline (2 min)

```bash
cd ../.. && make destroy
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
| No `backend.tf` in bootstrap | The state chicken-and-egg |
| `data "terraform_remote_state"` | Workspaces share values via state |
| `module "…"` with a registry source | Modules = reusable bundles of resources |
| `sensitive = true` | Output hygiene |
| `make destroy` | IaC means the whole stack is disposable |

---

## If something fails

Check `docs/TROUBLESHOOTING.md` — it covers the exact errors beginners hit
(`BucketAlreadyExists`, state-lock, `plan`/`validate` needing init,
`terraform_remote_state` before network, image pull, destroy order).
