locals {
  pass = jsondecode(data.aws_secretsmanager_secret_version.version.secret_string)["password"]
}

data "aws_secretsmanager_secret" "secret" {
  arn = "arn:aws:secretsmanager:us-east-1:600005164000:secret:tf_secret-otPZg4"
}

data "aws_secretsmanager_secret_version" "version" {
  secret_id = data.aws_secretsmanager_secret.secret.id
}

resource "aws_db_instance" "mysql" {
  allocated_storage       = 10
  backup_retention_period = 7
  db_name                 = "mydb"
  engine                  = "mysql"
  engine_version          = "8.0.33"
  identifier              = "tf-mysql-db"
  instance_class          = "db.t3.micro"
  username                = "mark"
  password                = local.pass
  parameter_group_name    = "default.mysql8.0"
  multi_az                = false
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.db_group.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
}

resource "aws_db_subnet_group" "db_group" {
  name       = "db_group"
  subnet_ids = var.private_subnet_id

  tags = {
    Name = "${var.env_code}-subnet-group"
  }
}

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
