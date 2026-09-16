resource "aws_ecs_cluster" "app" {
  name = "${var.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enhanced"
  }

  tags = {
    Name = "${var.name_prefix}-cluster"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = var.name_prefix
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = var.task_cpu
  memory = var.task_memory

  execution_role_arn = aws_iam_role.execution.arn
  task_role_arn      = aws_iam_role.task.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([{
    name      = local.container_name
    image     = var.container_image
    essential = true

    portMappings = [
      {
        containerPort = var.application_port
        hostPort      = var.application_port
        protocol      = "tcp"
      }
    ]

    environment = [
      {
        name  = "PORT"
        value = tostring(var.application_port)
      },
      {
        name  = "APP_ENV"
        value = var.environment
      },
      {
        name  = "APP_VERSION"
        value = var.app_version
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"

      options = {
        awslogs-group         = aws_cloudwatch_log_group.app.name
        awslogs-region        = local.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }

    stopTimeout = 60
  }])

  tags = {
    Name = "${var.name_prefix}-task"
  }
}

resource "aws_ecs_service" "app" {
  name            = "${var.name_prefix}-service"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.min_tasks

  launch_type         = "FARGATE"
  platform_version    = "LATEST"
  scheduling_strategy = "REPLICA"

  availability_zone_rebalancing = "ENABLED"

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  health_check_grace_period_seconds = 60
  wait_for_steady_state             = true

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = local.container_name
    container_port   = var.application_port
  }

  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"

  tags = {
    Name = "${var.name_prefix}-service"
  }

  lifecycle {
    # Target tracking owns desired_count after creation. Changing only
    # var.min_tasks will not resize an existing ECS Service while this is ignored.
    ignore_changes = [desired_count]
  }

  depends_on = [
    aws_lb_listener.http,
    aws_lb_listener.https,
    aws_iam_role_policy_attachment.execution
  ]
}

resource "aws_appautoscaling_target" "ecs_service" {
  min_capacity = var.min_tasks
  max_capacity = var.max_tasks

  resource_id = "service/${aws_ecs_cluster.app.name}/${aws_ecs_service.app.name}"

  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  name        = "${var.name_prefix}-cpu-target"
  policy_type = "TargetTrackingScaling"

  resource_id        = aws_appautoscaling_target.ecs_service.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 60

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_out_cooldown = 60
    scale_in_cooldown  = 300
  }
}