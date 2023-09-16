output "db_address" {
  value = module.db.db_instance_address
}

output "db_username" {
  value     = module.db.db_instance_username
  sensitive = true
}

output "pass" {
  #value     = nonsensitive(sha256(var.password))
  value     = var.password
  sensitive = true
}
