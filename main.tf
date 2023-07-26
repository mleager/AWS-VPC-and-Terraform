
# Public EC2 Instance ( Bastion Host )
resource "aws_instance" "public_webserver" {
  ami                  = var.ami
  instance_type        = var.instance_type
  iam_instance_profile = var.iam_instance_profile
  key_name             = var.key_name
  subnet_id            = aws_subnet.public_subnet_a.id

  vpc_security_group_ids = [aws_security_group.ssh-access.id]

  tags = {
    Name = "Public EC2 Instance"
  }
}


# Private EC2 Instance
resource "aws_instance" "webserver" {
  ami                         = var.ami
  instance_type               = var.instance_type
  iam_instance_profile        = var.iam_instance_profile
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.private_subnet_a.id
  user_data_replace_on_change = true
  user_data                   = <<EOF
    #!/bin/bash -xe
    if [ -f "/etc/yum.conf" ]; then
        sudo sed -i "s/^timeout=.*/timeout=180/" /etc/yum.conf
    fi
    echo "#!/bin/bash
    uptime && yum -y update" > /home/ec2-user/yum_update.sh
    sudo chmod +x /home/ec2-user/yum_update.sh
    sudo sh /home/ec2-user/yum_update.sh > /home/ec2-user/yum_output.txt
    echo "#!/bin/bash
    echo \"0 * * * 1-5 /home/ec2-user/yum_update.sh\" | crontab" > /home/ec2-user/crontab_entry.sh
    sudo chmod +x /home/ec2-user/crontab_entry.sh
    sudo sh /home/ec2-user/crontab_entry.sh
    crontab -l > /home/ec2-user/list_crons.txt
    EOF

  vpc_security_group_ids = [ aws_security_group.ssh-access.id ]

  tags = {
    Name = "Example EC2 Instance"
  }
  depends_on = [aws_security_group.ssh-access]
}


# VPC
resource "aws_vpc" "vpc_a" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "VPC A"
  }
}


# VPC Security Group 
resource "aws_security_group" "ssh-access" {
  name = "ssh-access-vpc"
  description = "Allow SSH on VPC A"
  vpc_id = aws_vpc.vpc_a.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

    egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}


## ------------  Public  ------------ ##

# 2 Public Subnets
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.vpc_a.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = var.az["1a"]
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet A"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.vpc_a.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.az["1b"]
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet B"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.vpc_a.id

  tags = {
    Name = "VPC - IGW"
  }
}


# Public Routing Table & 2 Routing Table Assocations
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.vpc_a.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id
  }

  tags = {
    Name = "Public RT"
  }
}

resource "aws_route_table_association" "public_rta_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "public_rta_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route.id
}


## ------------  Private  ------------ ##

# 2 Private Subnets
resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.vpc_a.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.az["1c"]

  tags = {
    Name = "Private Subnet A"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.vpc_a.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.az["1d"]

  tags = {
    Name = "Private Subnet B"
  }
}


# 2 NAT Gateways
resource "aws_nat_gateway" "ngw_a" {
  allocation_id = aws_eip.nat_eip_a.id
  subnet_id     = aws_subnet.public_subnet_a.id

  tags = {
    Name = "NAT Gateway A"
  }
}

resource "aws_nat_gateway" "ngw_b" {
  allocation_id = aws_eip.nat_eip_b.id
  subnet_id     = aws_subnet.public_subnet_b.id

  tags = {
    Name = "NAT Gateway B"
  }
}


# 2 EIPs
resource "aws_eip" "nat_eip_a" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.vpc_igw]
}

resource "aws_eip" "nat_eip_b" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.vpc_igw]
}



# 2 Private Routing Tables & 2 Routing Table Associations
resource "aws_route_table" "private_route_a" {
  vpc_id = aws_vpc.vpc_a.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw_a.id
  }

  tags = {
    Name = "Private RT A"
  }
}

resource "aws_route_table" "private_route_b" {
  vpc_id = aws_vpc.vpc_a.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw_b.id
  }

  tags = {
    Name = "Private RT B"
  }
}

resource "aws_route_table_association" "private_rta_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_route_a.id
}

resource "aws_route_table_association" "private_rta_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_route_b.id
}
