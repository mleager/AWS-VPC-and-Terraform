resource "aws_security_group" "private" {
  name        = "${var.env_code}-private"
  description = "Allow VPC Traffic"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow HTTP Traffic from Load Balancer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.load_balancer_sg]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  # egress {
  #   from_port   = 3306
  #   to_port     = 3306
  #   protocol    = "tcp"
  #   #security_groups = [var.db_sg]
  #   cidr_blocks = [ "0.0.0.0/0" ]
  # }

  tags = {
    Name = "${var.env_code}-private"
  }
}
