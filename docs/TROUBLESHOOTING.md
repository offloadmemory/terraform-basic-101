# Troubleshooting

The errors beginners actually hit with this repository — each with the
cause and the fix. If you see something not listed here, open an issue.

---

## 1. `BucketAlreadyExists` / `BucketAlreadyOwnedByYou`

```
Error: creating S3 bucket (terraform-basic-101-tfstate): BucketAlreadyExists:
    The requested bucket name is not available.
```

**Cause:** S3 bucket names are **globally unique** — someone else (or a
previous run) already owns `terraform-basic-101-tfstate`.

**Fix:** pick a unique name (e.g. add your initials), then change it in
**two places**:

1. `infra/bootstrap/terraform.tfvars` → `state_bucket_name`
2. `infra/backend.tf` → the `bucket` line

Then `terraform apply` again in bootstrap, and `terraform init` again in
`infra/` (it re-reads the backend).

---

## 2. `Error: acquiring the state lock` / `412 Precondition Failed`

```
Error: acquiring the state lock
Error message: ConditionalCheckFailed: The conditional request failed
```

**Cause:** another `terraform` run (yours or a teammate's) is currently
planning/applying the same configuration. S3-native locking (`.tflock`)
prevents two runs from clobbering state.

**Fix (do these in order):**

1. **Wait** — the other run probably finishes in seconds.
2. If a previous run *crashed* and left the lock behind, force-release it:

   ```bash
   # find the lock ID from the error output
   terraform force-unlock <LOCK_ID>
   ```

   Only force-unlock when you're sure nobody is actively running Terraform
   on that configuration.

---

## 3. `Error: Backend initialization required` / "Please run `terraform init`"

**Cause:** you ran `plan`/`apply`/`validate` in a fresh checkout without
initializing first.

**Fix:**

```bash
terraform init   # downloads providers + modules, sets up the backend
```

Run it in every configuration you touch. The Makefile scripts do it for you.

---

## 4. `Error: Unsupported argument` pointing at a module call

```
Error: Unsupported argument
  on main.tf line X, in module "db":
  An argument named "foo" is not expected here.
```

**Cause:** you added an input the module doesn't declare (or you're on a
different module version than this repo pins).

**Fix:** check the module's documentation on the Terraform Registry for the
version pinned in `main.tf` (e.g. `terraform-aws-modules/rds/aws` v7.2.1).
Registry module pages list every input. If you bumped the module `version`,
older inputs may have been renamed.

---

## 5. Applying `infra` before bootstrap / "S3 bucket does not exist"

```
Error: Backend initialization failed:
  Error: error loading state: S3 bucket does not exist ...
```

**Cause:** you ran `terraform init` in `infra/` before `infra/bootstrap` was
applied — the state bucket doesn't exist yet.

**Fix:** run the bootstrap first:

```bash
cd infra/bootstrap && terraform init && terraform apply
cd .. && terraform init
```

(This repo has **no `terraform_remote_state` anywhere** — `database.tf` and
`ecs.tf` read the VPC directly from `module.vpc.*`, so the old "network
state file not found" failure mode doesn't exist here.)

---

## 6. The app URL shows `503` / empty page

**Cause 1 — the Fargate task is still starting.** The ALB reports 503 while
the first deployment runs (image pull + health checks can take a few
minutes).

**Fix:** wait 2–3 minutes, refresh. Watch it come up:

```bash
aws ecs describe-services --cluster basic-101-cluster \
  --services basic-101-service --region us-east-1 \
  --query "services[0].deployments[0].desiredCount" --output text
```

**Cause 2 — the container image doesn't exist or isn't web-servable.** The
repo defaults to `kartikmanimuthu/hello-101:latest` (a tiny HTTP server).
If it's unavailable, or you swapped in an image that doesn't serve HTTP/80,
the target-group health check fails forever.

**Fix:** point at any public image that serves HTTP on port 80:

```hcl
# infra/terraform.tfvars
container_image = "nginxdemos/hello:latest"
```

then:

```bash
cd infra && terraform apply
```

---

## 7. `make destroy` stops / "would be protected" (deletion protection)

```
Error: ... cannot be deleted: the resource is protected by deletion protection
```

**Cause:** `db_deletion_protection = true` in `infra/terraform.tfvars` —
set for production hardening.

**Fix:** temporarily set it to `false`, `apply`, then destroy. (In this
repo the defaults are already destroy-friendly, so you'll only hit this if
you copied `infra/` to a new environment and hardened it.)

---

## 8. Destroying the bucket while the stack is still up / "bucket not empty"

If you destroy `infra/bootstrap` while `infra` still exists, the bucket
still holds the state file and `terraform destroy` refuses.

**Fix:** always destroy the stack first, then (optionally) the bucket:

```bash
make destroy                            # destroys infra/ (bootstrap skipped)
./scripts/destroy.sh --include-bootstrap # only when you're sure
```

Inside `infra/`, `terraform destroy` orders everything itself (ECS → DB →
network), so you can't hit the old "delete the VPC while it has resources"
`DependencyViolation` error.

---

## 9. `terraform output` shows nothing / "no outputs defined"

**Cause:** you're in the wrong folder (outputs live in the configuration
that declared them), or the configuration was never applied.

**Fix:**

```bash
cd infra
terraform apply        # if not applied yet
terraform output alb_dns_name
```

---

## 10. Sensitive outputs are hidden

```
Outputs:
  db_endpoint = <sensitive>
```

**That's correct behaviour.** Show them explicitly:

```bash
terraform output -json db_endpoint
```

---

## 11. tflint: "module should specify a version"

**Cause:** a registry module call without a `version` pin.

**Fix:** add `version = "~> X.Y.Z"` to the module block (every module in
this repo already has one — this appears if you add a new module).

---

## 12. `pre-commit` hooks "Skipped / no files to check"

**Cause:** you ran `pre-commit run --all-files` before any `git commit` —
hooks only see *tracked* files.

**Fix:** commit first (`git add -A && git commit`), then
`pre-commit run --all-files` — or simply rely on the hooks running
automatically on the next commit.
