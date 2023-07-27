
# VPC
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}


# VPC Security Group 
resource "aws_security_group" "ssh-access" {
  name        = "ssh-access-vpc"
  description = "Allow SSH on VPC A"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "VPC Security Group"
  }
}


# 2 Public Subnets
resource "aws_subnet" "public" {
  count = length(local.public_cidr)

  vpc_id     = aws_vpc.main.id
  cidr_block = local.public_cidr[count.index]

  availability_zone = element(var.public_availability_zones, count.index)

  map_public_ip_on_launch = true

  tags = {
    Name = "public${count.index}"
  }
}


# 2 Private Subnets
resource "aws_subnet" "private" {
  count = length(local.private_cidr)

  vpc_id     = aws_vpc.main.id
  cidr_block = local.private_cidr[count.index]

  availability_zone = element(var.private_availability_zones, count.index)

  tags = {
    Name = "private${count.index}"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}


# 2 EIPs
resource "aws_eip" "nat" {
  count = length(local.public_cidr)

  domain = "vpc"

  tags = {
    Name = "nat${count.index}"
  }

  depends_on = [aws_internet_gateway.main]
}


# 2 NAT Gateways
resource "aws_nat_gateway" "main" {
  count = length(local.public_cidr)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "main${count.index}"
  }
}


# Public Routing Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public"
  }
}


# 2 Private Routing Tables
resource "aws_route_table" "private" {
  count = length(local.private_cidr)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "private${count.index}"
  }
}


# 2 Public Routing Associations
resource "aws_route_table_association" "public" {
  count = length(local.public_cidr)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


# 2 Private Routing Associations
resource "aws_route_table_association" "private" {
  count = length(local.private_cidr)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
