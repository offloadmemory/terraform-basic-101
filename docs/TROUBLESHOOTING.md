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

1. `environments/bootstrap/terraform.tfvars` → `state_bucket_name`
2. every `backend.tf` → the `bucket` line (network, database, ecs)

Then `terraform apply` again in bootstrap, and `terraform init` again in the
other workspaces (they re-read the backend).

---

## 2. `Error: acquiring the state lock` / `412 Precondition Failed`

```
Error: acquiring the state lock
Error message: ConditionalCheckFailed: The conditional request failed
```

**Cause:** another `terraform` run (yours or a teammate's) is currently
planning/applying the same workspace. S3-native locking (`.tflock`) prevents
two runs from clobbering state.

**Fix (do these in order):**

1. **Wait** — the other run probably finishes in seconds.
2. If a previous run *crashed* and left the lock behind, force-release it:

   ```bash
   # find the lock ID from the error output
   terraform force-unlock <LOCK_ID>
   ```

   Only force-unlock when you're sure nobody is actively running Terraform
   on that workspace.

---

## 3. `Error: Backend initialization required` / "Please run `terraform init`"

**Cause:** you ran `plan`/`apply`/`validate` in a fresh checkout without
initializing first.

**Fix:**

```bash
terraform init   # downloads providers + modules, sets up the backend
```

Run it in every workspace you touch. The Makefile scripts do it for you.

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

## 5. `terraform_remote_state` errors / `The specified key does not exist`

```
Error: error loading state: S3 bucket does not exist ...
  OR
Error: failed to load state: no such object: dev/network/terraform.tfstate
```

**Cause:** `database` or `ecs` is being planned/applied **before** `network`
(or before bootstrap created the bucket).

**Fix:** apply in dependency order:

```bash
make apply   # bootstrap → network → database → ecs
```

The `terraform_remote_state` data source *requires* the network state file
to already exist in S3.

---

## 6. The app URL shows `503` / empty page

**Cause 1 — the Fargate task is still starting.** The ALB reports 503 while
the first deployment runs (image pull + health checks can take a few
minutes).

**Fix:** wait 2–3 minutes, refresh. Watch it come up:

```bash
aws ecs describe-services --cluster basic-101-dev-cluster \
  --services basic-101-dev-service --region us-east-1 \
  --query "services[0].deployments[0].desiredCount" --output text
```

**Cause 2 — the container image doesn't exist or isn't web-servable.** The
repo defaults to `kartikmanimuthu/hello-101:latest` (a tiny HTTP server).
If it's unavailable, or you swapped in an image that doesn't serve HTTP/80,
the target-group health check fails forever.

**Fix:** point at any public image that serves HTTP on port 80:

```hcl
# environments/dev/ecs/terraform.tfvars
container_image = "nginxdemos/hello:latest"
```

then:

```bash
cd environments/dev/ecs && terraform apply
```

---

## 7. `make destroy` stops / "would be protected" (deletion protection)

```
Error: ... cannot be deleted: the resource is protected by deletion protection
```

**Cause:** `db_deletion_protection = true` in `database/terraform.tfvars` —
set for production hardening.

**Fix:** temporarily set it to `false`, `apply`, then destroy. (In this
repo the dev defaults are already destroy-friendly, so you'll only hit this
if you copied the environment and hardened it.)

---

## 8. Destroy order matters

Destroying `network` while `database`/`ecs` still exist fails:

```
Error: error deleting subnet: DependencyViolation
```

**Cause:** the VPC still has resources attached to it.

**Fix:** always destroy in reverse order:

```bash
make destroy   # ecs → database → network (bootstrap skipped by default)
```

---

## 9. `terraform output` shows nothing / "no outputs defined"

**Cause:** you're in the wrong workspace folder (outputs live in the
workspace that declared them), or the workspace was never applied.

**Fix:**

```bash
cd environments/dev/ecs
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
