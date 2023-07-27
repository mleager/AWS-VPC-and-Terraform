
# EC2 Instance
resource "aws_instance" "public_webserver" {
  ami                         = var.ami
  instance_type               = var.instance_type
  associate_public_ip_address = true
  iam_instance_profile        = var.iam_instance_profile
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public[0].id

  vpc_security_group_ids = [aws_security_group.public.id]

  tags = {
    Name = "${var.env_code}-public"
  }
}

# Public Security Group
resource "aws_security_group" "public" {
  name        = "${var.env_code}-public"
  description = "Allow SSH Access"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from public"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["76.153.164.196/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_code}-public"
  }
}

# Private EC2 Instance
resource "aws_instance" "private_webserver" {
  ami                         = var.ami
  instance_type               = var.instance_type
  iam_instance_profile        = var.iam_instance_profile
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.private[0].id

  vpc_security_group_ids = [aws_security_group.private.id]

  tags = {
    Name = "${var.env_code}-private"
  }
}

# Private Security Group
resource "aws_security_group" "private" {
  name        = "${var.env_code}-private"
  description = "Allow VPC Traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_code}-private"
  }
}