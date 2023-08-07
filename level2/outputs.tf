output "db_address" {
  value = module.rds.db_instance_address
}

# output "db_endpoint" {
#   value = module.rds.db_instance_endpoint
# }

output "db_username" {
  value     = module.rds.db_instance_username
  sensitive = true
}
