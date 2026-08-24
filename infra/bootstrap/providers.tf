# Provider configuration for the bootstrap workspace.
# Region and profile come from variables so the same files work on any machine.
provider "aws" {
  region  = var.region
  profile = var.profile
}
