locals {
  pass = jsondecode(data.aws_secretsmanager_secret_version.version.secret_string)["password"]
}

data "aws_secretsmanager_secret" "secret" {
  arn = "arn:aws:secretsmanager:us-east-1:600005164000:secret:tf_secret-otPZg4"
}

data "aws_secretsmanager_secret_version" "version" {
  secret_id = data.aws_secretsmanager_secret.secret.id
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "tf-mysql-db"

  create_db_subnet_group    = true
  create_db_option_group    = false
  create_db_parameter_group = false

  engine            = "mysql"
  engine_version    = "8.0.33"
  instance_class    = "db.t3.micro"
  allocated_storage = 5

  db_name  = "tfdb"
  username = "mark"
  password = local.pass
  port     = "3306"

  multi_az               = false
  db_subnet_group_name   = "db-group"
  subnet_ids             = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}
