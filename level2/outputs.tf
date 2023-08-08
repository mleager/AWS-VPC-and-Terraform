output "db_address" {
  value = module.db.db_instance_address
}

output "db_username" {
  value     = module.db.db_instance_username
  sensitive = true
}

output "pass" {
  value     = local.pass
  sensitive = true
}
