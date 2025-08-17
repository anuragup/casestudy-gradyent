module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  azs                  = var.availability_zones
  env                  = var.env
}
#track changes in eks-terraform/main.tf