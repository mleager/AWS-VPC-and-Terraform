variable "env_code" {}

variable "vpc_id" {}

variable "private_subnet_id" {}

variable "asg_sg" {}

# variable "secret_value" {
#   default = jsondecode(data.aws_secretsmanager_secret_version.version.secret_string)["password"]
# }
