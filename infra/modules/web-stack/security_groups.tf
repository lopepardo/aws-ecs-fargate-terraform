resource "aws_security_group" "alb" {
  name                   = "${var.name_prefix}-alb-sg"
  description            = "Traffic for the public ALB"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  tags = {
    Name = "${var.name_prefix}-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTP from Internet"

  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  for_each = local.https_resources

  security_group_id = aws_security_group.alb.id
  description       = "HTTPS from Internet"

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_tasks" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.tasks.id
  description                  = "HTTP to the Express API"

  from_port   = var.application_port
  to_port     = var.application_port
  ip_protocol = "tcp"
}

resource "aws_security_group" "tasks" {
  name                   = "${var.name_prefix}-tasks-sg"
  description            = "Traffic for private ecs tasks"
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

  tags = {
    Name = "${var.name_prefix}-tasks-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "tasks_from_alb" {
  security_group_id            = aws_security_group.tasks.id
  referenced_security_group_id = aws_security_group.alb.id
  description                  = "API traffic only from ALB"

  from_port   = var.application_port
  to_port     = var.application_port
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "tasks_https_out" {
  security_group_id = aws_security_group.tasks.id
  description       = "ECR, CloudWatch and external dependencies"

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"
}
