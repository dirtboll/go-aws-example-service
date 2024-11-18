resource "aws_lb" "main" {
  name               = provider::slugify::slug("${local.application_name}-${var.environment}-alb")
  load_balancer_type = "application"
  subnets            = aws_subnet.main_public[*].id
  security_groups = [
    aws_security_group.alb.id
  ]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.id
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.id
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate_validation.app.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.id
  }
}


resource "aws_lb_target_group" "app" {
  name        = provider::slugify::slug("${local.application_name}-${var.environment}")
  vpc_id      = aws_vpc.main.id
  protocol    = "HTTP"
  port        = 8080
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/_healthz"
    port                = 8080
    matcher             = 200
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}


