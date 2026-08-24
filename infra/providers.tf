# Provider configuration for the single infrastructure configuration.
# Region and profile come from variables so the same files work on any machine.
provider "aws" {
  region  = var.region
  profile = var.profile
}
