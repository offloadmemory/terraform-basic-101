# Per-environment values for the dev network.
# These are the ONLY things you change when you later copy this folder to
# create a "staging" or "prod" environment (see docs/ARCHITECTURE.md).
region               = "us-east-1"
profile              = "dev"
vpc_name             = "basic-101-dev-vpc"
vpc_cidr             = "10.0.0.0/16"
azs                  = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
