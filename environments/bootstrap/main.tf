# Bootstrap workspace
#
# Creates the S3 bucket that stores Terraform state for every other workspace.
# This is the classic "chicken-and-egg" of Terraform: the state backend must
# exist BEFORE terraform can run against it — so this workspace has NO
# backend.tf and keeps its state locally on your machine.
#
# Run once, first:
#   cd environments/bootstrap && terraform init && terraform apply
#
# The state bucket is created from the official Terraform Registry module
# terraform-aws-modules/s3-bucket/aws — no custom module needed.
module "state_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.15.4"

  bucket = var.state_bucket_name
  acl    = "private"

  # Versioning lets you recover a previous state file if it is ever
  # overwritten or corrupted — strongly recommended for state buckets.
  versioning = {
    enabled = true
  }

  # Encrypt the state at rest (it can contain sensitive values).
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  # State buckets must never be public.
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  force_destroy = false

  tags = var.tags
}
