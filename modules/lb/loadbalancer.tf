resource "aws_lb" "alb" {
  name               = "tf-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_id

  access_logs {
    bucket  = "tf-state-mentorship"
    prefix  = "test-lb"
    enabled = false
  }

  tags = {
    Name = "${var.env_code}-alb"
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold = 2
    interval          = 30
    path              = "/"
    port              = "80"
    protocol          = "HTTP"
    timeout           = 25
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.env_code}-alb-sg"
  description = "Allow Incoming HTTP Access for ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP Traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_code}-alb-sg"
  }
}
