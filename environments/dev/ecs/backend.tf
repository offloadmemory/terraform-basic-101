terraform {
  backend "s3" {
    bucket       = "terraform-basic-101-tfstate"
    key          = "dev/ecs/terraform.tfstate"
    region       = "us-east-1"
    profile      = "dev"
    use_lockfile = true
    encrypt      = true
  }
}
