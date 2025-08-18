# EKS on AWS (Terraform) — Case Study

I built a small, secure EKS cluster with Terraform.

Here are the components I used :
- Used a VPC across 3 Availability Zones (public subnets for EKS nodes, tied to public_subnet_cidrs).
- Implemented EKS with a managed node group, secured by an IAM role (eks-node-role).
- Configured one managed node group: main (using spot instances with capacity_type = "SPOT").
- Set up security with an aws_security_group in modules/vpc/main.tf for restricting inbound traffic (ports 80/443, 10250, 22) and allowing all outbound.
