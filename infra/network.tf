# Network resources — the VPC everything else lives in.
#
# This uses the official Terraform Registry module terraform-aws-modules/vpc/aws,
# so there is no hand-written network module in this repo — the registry module
# creates the VPC, subnets, internet gateway, NAT gateway and route tables for us.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.7.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.azs
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  # One NAT gateway per AZ. NAT gives private subnets outbound internet
  # access (needed by the ECS task to pull images) without exposing them.
  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = var.tags
}
