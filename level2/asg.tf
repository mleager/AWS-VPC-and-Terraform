data "aws_ami" "amazonlinux2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] # "137112412989"
}

module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = "${var.env_code}-asg"

  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  security_groups           = [module.private_sg.security_group_id]
  target_group_arns         = module.alb.target_group_arns
  vpc_zone_identifier       = data.terraform_remote_state.level1.outputs.private_subnet_id
  force_delete              = true

  launch_template_name        = "${var.env_code}-launch-template"
  launch_template_description = "Terraform Launch template"
  update_default_version      = true
  launch_template_version     = "$Latest"

  image_id      = data.aws_ami.amazonlinux2.id
  instance_name = var.env_code
  instance_type = var.instance_type
  user_data     = base64encode(file("${path.module}/user_data.sh"))

  create_iam_instance_profile = true
  iam_instance_profile_name   = "ssm-profile"
  iam_role_name               = "${var.env_code}-AmazonSSMManagedInstanceCore"
  iam_role_path               = "/ec2/"
  iam_role_description        = "IAM Role for SSM Access via EC2"
  iam_role_tags = {
    CustomIamRole = "No"
  }
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = {
    Environment = "Terraform"
    Name        = "${var.env_code}"
  }

  autoscaling_group_tags = {
    Name = "${var.env_code}-asg"
  }
}

# resource "aws_security_group" "private" {
#   name        = "${var.env_code}-private"
#   description = "Allow VPC Traffic"
#   vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

#   ingress {
#     description     = "Allow HTTP Traffic from Load Balancer"
#     from_port       = 80
#     to_port         = 80
#     protocol        = "tcp"
#     security_groups = [module.alb.security_group_id]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = -1
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.env_code}-private"
#   }
# }

module "private_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.env_code}-private"
  description = "Allow HTTP Traffic from Load Balancer"
  vpc_id      = data.terraform_remote_state.level1.outputs.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "tcp"
      description = "Allow HTTPS to ALB"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}
