# EKS on AWS (Terraform) — Case Study

I built a small, secure EKS cluster with Terraform.

Here are the components I used :
- Used a VPC across 3 Availability Zones (public subnets for EKS nodes, tied to public_subnet_cidrs).
- Implemented EKS with a managed node group, secured by an IAM role (eks-node-role).
- Configured one managed node group: main (using spot instances with capacity_type = "SPOT").
- Set up security with an aws_security_group in modules/vpc/main.tf for restricting inbound traffic (ports 80/443, 10250, 22) and allowing all outbound.

Here is the diagram I have tried to create for refrence: 

<img width="915" height="1111" alt="image" src="https://github.com/user-attachments/assets/8d89e129-357e-46a0-a720-bf555441b2c5" />



## Addressing Solution Requirements

- **Scalability**: The EKS cluster uses a managed node group with `min_size = 2`, `max_size = 10`, and `desired_size = 3`, allowing automatic scaling based on load. Spot instances and public subnet deployment across three AZs ensure resource availability and fault tolerance.

- **Monitoring**: Security Groups and pod configurations include annotations for Prometheus scraping (e.g., `/metrics` on port 8080), integrated via a ServiceMonitor for real-time metrics tracking.

- **Cost**: Utilization of `t3.medium` spot instances (`capacity_type = "SPOT"`) reduces costs significantly compared to on-demand instances. Public subnets eliminate NAT Gateway expenses, and resource limits (e.g., 500m CPU, 512Mi memory) optimize resource use.

- **Ease of Use**: Terraform modules (`vpc`, `eks`) simplify infrastructure setup, while Helm charts (`tech-interview-app`) streamline application deployment. Clear `README.md` instructions and configurable `values.yaml` enhance accessibility.

## Alternative Setup

This alternative setup uses a VPC across three AZs with private subnets for EKS nodes (e.g., ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]) and NAT Gateways for safe outbound traffic. It includes EKS with a private endpoint, two node groups—system on on-demand instances for stability and apps on spot instances for savings—plus the AWS Load Balancer Controller for ingress. This balances security and cost 

Internet
   |
  IGW
   |
 [ALB] (public subnets A/B)
   | \
   |  \  (targets)
   v   v
[Pods A]   [Pods B]  (private subnets A/B)
   |          |
   |          |
0.0.0.0/0  0.0.0.0/0
  |          |
[NAT A]    [NAT B]
   \        /
     ---> IGW ---> Internet
