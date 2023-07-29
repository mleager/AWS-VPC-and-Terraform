data "aws_ami" "amazonlinux2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] # "137112412989"
}

resource "aws_instance" "public_webserver" {
  ami                         = data.aws_ami.amazonlinux2.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  iam_instance_profile        = var.iam_instance_profile
  key_name                    = var.key_name
  subnet_id                   = data.terraform_remote_state.level1.outputs.public_subnet_id[0]
  user_data = file("user_data.sh")

  vpc_security_group_ids = [aws_security_group.public.id]

  tags = {
    Name = "${var.env_code}-public"
  }
}

resource "aws_security_group" "public" {
  name        = "${var.env_code}-public"
  description = "Allow SSH Access"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  ingress {
    description = "SSH from public"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["76.153.164.196/32"]
  }

  ingress {
    description = "Allow HTTP Traffic"
    from_port   = 80
    to_port     = 80
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
    Name = "${var.env_code}-public"
  }
}

resource "aws_instance" "private_webserver" {
  ami                  = data.aws_ami.amazonlinux2.id
  instance_type        = var.instance_type
  iam_instance_profile = var.iam_instance_profile
  key_name             = var.key_name
  subnet_id            = data.terraform_remote_state.level1.outputs.private_subnet_id[0]

  vpc_security_group_ids = [aws_security_group.private.id]

  tags = {
    Name = "${var.env_code}-private"
  }
}

resource "aws_security_group" "private" {
  name        = "${var.env_code}-private"
  description = "Allow VPC Traffic"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.level1.outputs.vpc_cidr]
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
