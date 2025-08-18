# EKS on AWS (Terraform) — Case Study

I built a small, secure EKS cluster with Terraform.

Here are the components I used :
- Used a VPC across 3 Availability Zones (public subnets for EKS nodes, tied to public_subnet_cidrs).
- Implemented EKS with a managed node group, secured by an IAM role (eks-node-role).
- Configured one managed node group: main (using spot instances with capacity_type = "SPOT").
- Set up security with an aws_security_group in modules/vpc/main.tf for restricting inbound traffic (ports 80/443, 10250, 22) and allowing all outbound.


## Addressing Solution Requirements

- **Scalability**: The EKS cluster uses a managed node group with `min_size = 2`, `max_size = 10`, and `desired_size = 3`, allowing automatic scaling based on load. Spot instances and public subnet deployment across three AZs ensure resource availability and fault tolerance.

- **Monitoring**: Security Groups and pod configurations include annotations for Prometheus scraping (e.g., `/metrics` on port 8080), integrated via a ServiceMonitor for real-time metrics tracking.

- **Cost**: Utilization of `t3.medium` spot instances (`capacity_type = "SPOT"`) reduces costs significantly compared to on-demand instances. Public subnets eliminate NAT Gateway expenses, and resource limits (e.g., 500m CPU, 512Mi memory) optimize resource use.

- **Ease of Use**: Terraform modules (`vpc`, `eks`) simplify infrastructure setup, while Helm charts (`tech-interview-app`) streamline application deployment. Clear `README.md` instructions and configurable `values.yaml` enhance accessibility.
