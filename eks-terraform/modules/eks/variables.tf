variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets where EKS places ENIs and nodes"
}

variable "worker_security_group_id" {
  type        = string
  description = "Workers SG ID (from VPC module)"
}

variable "cost_center" {
  type        = string
  description = "Tag: Cost center"
}

variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}
