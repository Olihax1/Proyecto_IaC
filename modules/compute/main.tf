# --- 1. ECS CLUSTER ---
resource "aws_ecs_cluster" "main" {
  name = "seabook-cluster-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# --- 2. APPLICATION LOAD BALANCER (ALB) ---
resource "aws_lb" "main" {
  name               = "seabook-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false
}

# --- 3. TARGET GROUPS (Blue y Green para despliegues seguros) ---
# Mejora RNF 17: Optimización de tiempos para soportar 15,000 usuarios
resource "aws_lb_target_group" "blue" {
  name        = "tg-user-blue-${var.environment}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  
  deregistration_delay = 30 # Reduce el tiempo de espera al drenar conexiones

  health_check {
    path                = "/health"
    interval            = 15  # Más frecuente para detectar fallas rápido
    timeout             = 5
    healthy_threshold   = 2   # Acelera el marcado como sano para escalado rápido
    unhealthy_threshold = 3
    matcher             = "200"
  }
}

resource "aws_lb_target_group" "green" {
  name        = "tg-user-green-${var.environment}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  
  deregistration_delay = 30 

  health_check {
    path                = "/health"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }
}

# --- 4. ALB LISTENER ---
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}

# --- 5. ECS SERVICE ---
resource "aws_ecs_service" "user" {
  name            = "user-service-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.user.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.ecs_security_group_id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue.arn
    container_name   = "user-app"
    container_port   = 80
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }
}

# --- 6. TASK DEFINITION (Mejorada con Logs para RNF 21) ---
resource "aws_ecs_task_definition" "user" {
  family                   = "user-task-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "user-app"
      image     = "nginx:latest" 
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      
      # Configuración de logs para auditoría y trazabilidad
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/seabook-user-${var.environment}"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# --- 7. AUTO SCALING (RNF 19: Escalabilidad Automática) ---
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 10 # Capacidad para absorber picos de demanda
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.user.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0 
  }
}

# --- 8. LOG GROUP (Necesario para la Task Definition) ---
resource "aws_cloudwatch_log_group" "user_log_group" {
  name              = "/ecs/seabook-user-${var.environment}"
  retention_in_days = 7
}