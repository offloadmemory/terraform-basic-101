variable "region" {
  description = "AWS region for the network"
  type        = string
}

variable "profile" {
  description = "AWS CLI profile used for the network"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "Availability zones to spread the subnets across"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets (one per AZ)"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets (one per AZ)"
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to all network resources"
  type        = map(string)
  default     = {}
}
