module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  azs                  = var.availability_zones
  env                  = var.env
}

module "eks" {
  source = "./modules/eks"

  cluster_name              = var.cluster_name
  vpc_id                    = module.vpc.vpc_id

  # PRIMARY: workers in PUBLIC subnets (public-node design, hardened SG)
  subnet_ids                = module.vpc.public_subnet_ids

  # ALTERNATIVE (private nodes): switch to this line instead
  # subnet_ids              = module.vpc.private_subnet_ids

  worker_security_group_id  = module.vpc.worker_security_group_id
  cost_center               = var.cost_center
  aws_account_id            = var.aws_account_id
}

# ---------------------------
# Hardened inbound rules for public-node design
# ---------------------------

# Allow EKS control-plane -> kubelet (10250) ONLY from cluster SG
resource "aws_security_group_rule" "kubelet_from_cluster" {
  type                     = "ingress"
  description              = "Allow EKS control-plane to kubelet"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id = module.eks.node_security_group_id
  source_security_group_id = module.eks.cluster_security_group_id
}

# If ALB targetType=instance, allow NodePort range from ALB SG
resource "aws_security_group_rule" "nodeport_from_alb" {
  count                    = var.alb_target_type == "instance" ? 1 : 0
  type                     = "ingress"
  description              = "Allow ALB to reach nodes on NodePort range"
  from_port                = 30000
  to_port                  = 32767
  protocol                 = "tcp"
  security_group_id = module.eks.node_security_group_id
  source_security_group_id = var.alb_security_group_id
}
