variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "AZs to spread across"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs (one per AZ)"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "gradyent-eks"
}

variable "cost_center" {
  description = "Tagging: cost center"
  type        = string
  default     = "gradyent-tech-interview"
}

variable "aws_account_id" {
  description = "AWS Account ID (used in tags or IRSA policies if needed)"
  type        = string
  default     = "000000000000"
}

# For public-node primary design:
# If you use ALB targetType=instance, we allow NodePort range from ALB SG.
# If you use targetType=ip (recommended), this can be left blank and no rule is created.
variable "alb_target_type" {
  description = "ALB target type for ingress (ip|instance)"
  type        = string
  default     = "ip"
  validation {
    condition     = contains(["ip", "instance"], var.alb_target_type)
    error_message = "alb_target_type must be 'ip' or 'instance'."
  }
}

variable "alb_security_group_id" {
  description = "ALB SG ID (only required when alb_target_type = instance)"
  type        = string
  default     = ""
}
