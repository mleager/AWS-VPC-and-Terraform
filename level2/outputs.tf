output "db_address" {
  value = module.db.db_instance_address
}

output "db_username" {
  value     = module.db.db_instance_username
  sensitive = true
}
