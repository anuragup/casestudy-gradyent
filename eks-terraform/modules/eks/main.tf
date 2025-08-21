# Wrapper around terraform-aws-modules/eks to keep inputs tidy and re-export useful outputs.

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.30"

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  # Single managed node group; public-node design is controlled by chosen subnets in root
  eks_managed_node_groups = {
    main = {
      name           = "main"
      min_size       = 2
      max_size       = 6
      desired_size   = 3
      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
      # Additional per-node SGs can be attached if you prefer:
      # security_groups = [var.worker_security_group_id]
      # But generally the module manages the node SG automatically.
    }
  }

  # Useful tags
  tags = {
    Environment = "prod"
    CostCenter  = var.cost_center
    Account     = var.aws_account_id
  }
}
