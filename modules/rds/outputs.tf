output "db_sg" {
  value = aws_security_group.db_sg.id
}

output "db_instance_address" {
  value = module.db.db_instance_address
}

output "db_instance_endpoint" {
  value = module.db.db_instance_endpoint
}

output "db_instance_username" {
  value = module.db.db_instance_username
}
