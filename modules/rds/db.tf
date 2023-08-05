data "aws_secretsmanager_secret" "secret" {
  arn = "arn:aws:secretsmanager:us-east-1:600005164000:secret:tf_secret-otPZg4"
}

data "aws_secretsmanager_secret_version" "version" {
  secret_id = data.aws_secretsmanager_secret.secret.id
}

resource "aws_db_instance" "mysql" {
  #availability_zone       =
  allocated_storage       = 10
  backup_retention_period = 7
  db_name                 = "mydb"
  engine                  = "mysql"
  engine_version          = "8.0.33"
  instance_class          = "db.t3.micro"
  username                = "mark"
  password                = var.password
  parameter_group_name    = "default.mysql5.7"
  multi_az                = false
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.private.id]
}

resource "aws_security_group" "db_sg" {
  name        = "${var.env_code}-db-sg"
  description = "Allow Incoming Traffic"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow HTTP Traffic to MySQL"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_code}-db-sg"
  }
}
