variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones"
}

variable "env" {
  type        = string
  description = "Environment tag/name"
}
