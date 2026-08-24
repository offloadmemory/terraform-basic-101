variable "state_bucket_name" {
  description = "Globally-unique name of the S3 bucket that stores Terraform state"
  type        = string
}

variable "region" {
  description = "AWS region where the state bucket lives"
  type        = string
}

variable "profile" {
  description = "AWS CLI profile used to create the bucket"
  type        = string
}

variable "tags" {
  description = "Tags applied to the state bucket"
  type        = map(string)
  default = {
    Project   = "terraform-basic-101"
    ManagedBy = "terraform"
  }
}
