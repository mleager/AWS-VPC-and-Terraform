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

  # Autoscaling group
  name = "${var.env_code}-asg"

  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  security_groups           = [aws_security_group.private.id]
  target_group_arns         = var.target_group_arn
  user_data                 = base64encode(file("${path.module}/user_data.sh"))
  vpc_zone_identifier       = var.private_subnet_id

  # Launch template
  launch_template_name        = "${var.env_code}-launch-template"
  launch_template_description = "Terraform Launch template"
  update_default_version      = true

  image_id          = var.ami
  instance_name     = var.env_code
  instance_type     = var.instance_type
  ebs_optimized     = true
  enable_monitoring = true

  # IAM role & instance profile
  create_iam_instance_profile = true
  iam_instance_profile_name   = "ssm-profile"
  iam_role_name               = "${var.env_code}-AmazonSSMManagedInstanceCore"
  iam_role_path               = "/ec2/"
  iam_role_description        = "IAM role example"
  iam_role_tags = {
    CustomIamRole = "Yes"
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
