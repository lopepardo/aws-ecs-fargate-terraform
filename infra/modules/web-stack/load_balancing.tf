resource "aws_lb_target_group" "app" {
  name        = "${var.name_prefix}-tg"
  port        = var.application_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  deregistration_delay = 60

  health_check {
    enabled             = true
    protocol            = "HTTP"
    port                = "traffic-port"
    path                = "/health"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.name_prefix}-tg"
  }
}

resource "aws_lb" "app" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"

  security_groups = [aws_security_group.alb.id]
  subnets         = var.public_subnet_ids

  # enable_deletion_protection = true
  drop_invalid_header_fields = true

  tags = {
    Name = "${var.name_prefix}-alb"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = local.https_enabled ? "redirect" : "forward"
    target_group_arn = local.https_enabled ? null : aws_lb_target_group.app.arn

    dynamic "redirect" {
      for_each = local.https_resources

      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }
}

resource "aws_lb_listener" "https" {
  for_each = local.https_resources

  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"

  certificate_arn = each.value.certificate_arn
  ssl_policy      = each.value.ssl_policy

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_route53_record" "app" {
  for_each = local.https_resources

  zone_id = each.value.route53_zone_id
  name    = each.value.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}
