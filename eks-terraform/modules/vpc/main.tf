resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.env}-vpc"
    Environment = var.env
  }
}

resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name                             = "${var.env}-private-subnet-${count.index}"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                    = "${var.env}-public-subnet-${count.index}"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.env}-igw" }
}

# EIPs for NATs (one per public subnet/AZ)
resource "aws_eip" "nat" {
  count = length(var.public_subnet_cidrs)
  tags  = { Name = "${var.env}-eip-${count.index}" }
}

resource "aws_nat_gateway" "main" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = { Name = "${var.env}-nat-${count.index}" }
}

# ---------------------------
# Route tables / associations
# ---------------------------

# Public RT -> Internet via IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.env}-public-rt" }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private RTs -> NAT per AZ (for private-subnet alternative + other private resources)
resource "aws_route_table" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  tags  = { Name = "${var.env}-private-rt-${count.index}" }
}

resource "aws_route" "private_nat" {
  count                  = length(var.private_subnet_cidrs)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# ---------------------------
# Workers Security Group
# ---------------------------
resource "aws_security_group" "workers" {
  name        = "${var.env}-eks-workers-sg"
  description = "EKS worker nodes"
  vpc_id      = aws_vpc.main.id

  # Ingress rules are added in root, after EKS module (need SG IDs there).
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.env}-eks-workers-sg" }
}
