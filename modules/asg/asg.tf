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

resource "aws_launch_configuration" "launch_config" {
  name_prefix          = "${var.env_code}-"
  image_id             = data.aws_ami.amazonlinux2.id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
  user_data            = file("${path.module}/user_data.sh")

  security_groups = [aws_security_group.private.id]
}

resource "aws_autoscaling_group" "asg" {
  name             = var.env_code
  desired_capacity = 2
  min_size         = 1
  max_size         = 3

  launch_configuration = aws_launch_configuration.launch_config.name
  target_group_arns    = [var.target_group_arn]
  vpc_zone_identifier  = var.private_subnet_id

  tag {
    key                 = "Name"
    value               = var.env_code
    propagate_at_launch = true
  }
}
