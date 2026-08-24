# NOTE: bucket names are GLOBALLY unique across all of AWS.
# If "terraform-basic-101-tfstate" is taken, change it here AND in every
# backend.tf (only dev/network has one — database and ecs reuse it).
state_bucket_name = "terraform-basic-101-tfstate"
region            = "us-east-1"
profile           = "dev"
