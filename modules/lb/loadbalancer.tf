module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "${var.env_code}-alb"

  load_balancer_type = "application"

  vpc_id  = var.vpc_id
  subnets = var.public_subnet_id
  #security_groups    = [aws_security_group.alb_sg.id]

  create_security_group = true
  security_group_name   = "${var.env_code}-alb-sg"
  security_group_rules = {
    ingress_all_https = {
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow Incoming HTTPS Access for ALB"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  target_groups = [
    {
      name_prefix      = "${var.env_code}-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = aws_acm_certificate.cert.arn
      target_group_index = 0
    }
  ]

  tags = {
    Name = "${var.env_code}"
  }
}
