# --- ECR ---
resource "aws_ecr_repository" "catalogo" {
  name = "${local.nombre}-catalogo"
  tags = local.tags
}

resource "aws_ecr_repository" "reservas" {
  name = "${local.nombre}-reservas"
  tags = local.tags
}

# --- ECS / Fargate + Cloud Map ---
resource "aws_service_discovery_private_dns_namespace" "ns" {
  name        = "${local.nombre}.local"
  description = "Service Discovery"
  vpc         = aws_vpc.principal.id
  tags        = local.tags
}

resource "aws_ecs_cluster" "cluster" {
  name = "${local.nombre}-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = local.tags
}

resource "aws_cloudwatch_log_group" "catalogo" {
  name              = "/${local.nombre}/catalogo"
  retention_in_days = 365
  tags              = local.tags
}

resource "aws_cloudwatch_log_group" "reservas" {
  name              = "/${local.nombre}/reservas"
  retention_in_days = 365
  tags              = local.tags
}

resource "aws_ecs_task_definition" "catalogo" {
  family                   = "${local.nombre}-catalogo"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_tarea.arn
  task_role_arn            = aws_iam_role.ecs_tarea.arn

  container_definitions = jsonencode([
    {
      name  = "catalogo"
      image = "${aws_ecr_repository.catalogo.repository_url}:latest"
      portMappings = [
        { containerPort = 8001, hostPort = 8001, protocol = "tcp" }
      ]
      environment = [
        { name = "AWS_REGION", value = var.region }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.catalogo.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "reservas" {
  family                   = "${local.nombre}-reservas"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_tarea.arn
  task_role_arn            = aws_iam_role.ecs_tarea.arn

  container_definitions = jsonencode([
    {
      name  = "reservas"
      image = "${aws_ecr_repository.reservas.repository_url}:latest"
      portMappings = [
        { containerPort = 8002, hostPort = 8002, protocol = "tcp" }
      ]
      environment = [
        { name = "AWS_REGION", value = var.region },
        { name = "SNS_TEMA_ARN", value = aws_sns_topic.reservas.arn }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.reservas.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}


resource "aws_ecs_service" "catalogo" {
  name            = "${local.nombre}-catalogo"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.catalogo.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [for s in aws_subnet.privadas : s.id]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg_catalogo.arn
    container_name   = "catalogo"
    container_port   = 8001
  }

  tags = local.tags
}

resource "aws_ecs_service" "reservas" {
  name            = "${local.nombre}-reservas"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.reservas.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [for s in aws_subnet.privadas : s.id]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg_reservas.arn
    container_name   = "reservas"
    container_port   = 8002
  }

  tags = local.tags
}