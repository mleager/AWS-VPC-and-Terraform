data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = var.private_cidr
  public_subnets  = var.public_cidr
  #database_subnets = var.private_cidr

  enable_nat_gateway = true
  single_nat_gateway = false

  vpc_tags = {
    Name = "${var.env_code}-vpc"
  }

  nat_gateway_tags = {
    Name = "nat"
  }

  nat_eip_tags = {
    Name = "nat-iep"
  }

  private_route_table_tags = {
    Name = "private-route"
  }

  public_route_table_tags = {
    Name = "public-route"
  }

  private_subnet_tags = {
    Name = "private-subnet"
  }

  public_subnet_tags = {
    Name = "public-subnet"
  }
}
