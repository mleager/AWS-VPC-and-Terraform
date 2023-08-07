resource "aws_security_group" "db_sg" {
  name        = "${var.env_code}-db-sg"
  description = "Allow Incoming Traffic"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow Incoming Traffic to MySQL"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.asg_sg]
  }

  tags = {
    Name = "${var.env_code}-db-sg"
  }
}
