module "rds" {
  source = "../modules/rds"

  env_code          = var.env_code
  vpc_id            = data.terraform_remote_state.level1.outputs.vpc_id
  private_subnet_id = data.terraform_remote_state.level1.outputs.private_subnet_id
  asg_sg            = module.asg.asg_sg 
}
