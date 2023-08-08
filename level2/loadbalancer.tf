data "aws_route53_zone" "main" {
  name = "mark-dns.de"
}

module "acm" {
  source = "terraform-aws-modules/acm/aws"

  domain_name         = "www.mark-dns.de"
  zone_id             = data.aws_route53_zone.main.id
  wait_for_validation = true
}

module "dns" {
  source = "terraform-aws-modules/route53/aws//modules/records"

  zone_id = data.aws_route53_zone.main.zone_id

  records = [
    {
      name    = "www"
      type    = "CNAME"
      records = [module.alb.lb_dns_name]
      ttl     = 3600
    }
  ]
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "${var.env_code}-alb"

  load_balancer_type = "application"

  vpc_id  = data.terraform_remote_state.level1.outputs.vpc_id
  subnets = data.terraform_remote_state.level1.outputs.public_subnet_id

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
      name_prefix          = "${var.env_code}-"
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "instance"
      deregistration_delay = 10

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthz"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 0
    }
  ]

  tags = {
    Name = "${var.env_code}"
  }
}
