output "security_group_id" {
  value = module.alb.security_group_id
}

output "target_group_arns" {
  value = module.alb.target_group_arns
}
