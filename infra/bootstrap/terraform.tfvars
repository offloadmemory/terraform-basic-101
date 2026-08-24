# NOTE: bucket names are GLOBALLY unique across all of AWS.
# If "terraform-basic-101-tfstate" is taken, change it here AND in
# ../backend.tf (the single configuration's S3 backend).
state_bucket_name = "terraform-basic-101-tfstate"
region            = "us-east-1"
profile           = "dev"
