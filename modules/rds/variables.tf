variable "secret_value" {
  default = jsondecode(data.aws_secretsmanager_secret_version.version.secret_string)["password"]
}
