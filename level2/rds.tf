data "aws_secretsmanager_secret" "secret" {
  arn = "arn:aws:secretsmanager:us-east-1:600005164000:secret:tf_secret-otPZg4"
}

data "aws_secretsmanager_secret_version" "version" {
  secret_id = data.aws_secretsmanager_secret.secret.id
}

locals {
  pass = jsondecode(data.aws_secretsmanager_secret_version.version.secret_string)["password"]
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
  subnet_ids             = data.terraform_remote_state.level1.outputs.private_subnet_id
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "${var.env_code}-db-sg"
  description = "Allow Incoming Traffic"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  ingress {
    description     = "Allow Incoming Traffic to MySQL"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.private.id]
  }

  tags = {
    Name = "${var.env_code}-db-sg"
  }
}
