output "db_sg" {
  value = aws_security_group.db_sg.id
}

output "rds_hostname" {
  value = aws_db_instance.mysql.address
}

output "rds_username" {
  value = aws_db_instance.mysql.username
}
