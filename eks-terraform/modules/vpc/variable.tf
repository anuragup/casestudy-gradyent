variable "vpc_cidr" {
  type = string
}
variable "private_subnet_cidrs" {
  type = list(string)
}
variable "public_subnet_cidrs" {
  type = list(string)
}
variable "azs" {
  type = list(string)
}
variable "env" {
  type = string
}
#track changes in eks-terraform/modules/vpc/variable.tf