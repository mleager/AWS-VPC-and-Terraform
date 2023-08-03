data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = var.env_code
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_cidr)

  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_cidr[count.index]

  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env_code}-public${count.index}"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_cidr)

  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_cidr[count.index]

  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.env_code}-private${count.index}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.env_code
  }
}

resource "aws_eip" "nat" {
  count = length(var.public_cidr)

  domain = "vpc"

  tags = {
    Name = "${var.env_code}-nat${count.index}"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count = length(var.public_cidr)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "nat-${count.index}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.env_code}-public"
  }
}

resource "aws_route_table" "private" {
  count = length(var.private_cidr)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "${var.env_code}-private${count.index}"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_cidr)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_cidr)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}