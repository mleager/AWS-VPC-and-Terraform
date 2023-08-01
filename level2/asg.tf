resource "aws_launch_configuration" "launch_config" {
  name_prefix          = "${var.env_code}-"
  image_id             = data.aws_ami.amazonlinux2.id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
  user_data            = file("user_data.sh")

  security_groups = [aws_security_group.private.id]
}

resource "aws_autoscaling_group" "asg" {
  name             = var.env_code
  desired_capacity = 2
  min_size         = 1
  max_size         = 3

  launch_configuration = aws_launch_configuration.launch_config.name
  target_group_arns    = [aws_lb_target_group.alb_tg.arn]
  vpc_zone_identifier  = data.terraform_remote_state.level1.outputs.private_subnet_id

  tag {
    key                 = "Name"
    value               = var.env_code
    propagate_at_launch = true
  }
}
