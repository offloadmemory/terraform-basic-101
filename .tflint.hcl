# TFLint configuration — static analysis for Terraform code.
#
# tflint catches provider-API-level mistakes that `terraform validate`
# cannot: invalid instance classes, hardcoded values, missing tags, etc.
#
# Run locally with:
#   tflint --init && tflint --recursive
plugin "aws" {
  enabled = true
  version = "0.35.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
