# --- 1. SECURITY GROUP: LOAD BALANCER (ALB) ---
# Cumple con RNF 20 (Cifrado en tránsito)
resource "aws_security_group" "alb" {
  name        = "seabook-alb-sg-${var.environment}"
  description = "Permite trafico HTTP y HTTPS desde internet"
  vpc_id      = var.vpc_id

  # Acceso estándar
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  # NUEVO: Soporte para HTTPS (Seguridad Transversal)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- 2. SECURITY GROUP: ECS (APLICACIÓN) ---
# Implementa Aislamiento de Red (RNF 18)
resource "aws_security_group" "ecs" {
  name        = "seabook-ecs-sg-${var.environment}"
  description = "Permite trafico solo desde el ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- 3. SECURITY GROUP: DATABASE (DYNAMODB / DAX) ---
# Requerimiento 2: Búsquedas rápidas vía DAX
resource "aws_security_group" "db" {
  name        = "seabook-db-sg-${var.environment}"
  description = "Permite trafico de la App hacia DAX"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8111 # Puerto por defecto de DAX
    to_port         = 8111
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- 4. ROLES DE IAM PARA ECS ---

# Rol de Ejecución (Para que AWS gestione el contenedor)
resource "aws_iam_role" "ecs_exec_role" {
  name = "seabook-ecs-exec-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_exec_policy" {
  role       = aws_iam_role.ecs_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Rol de Tarea (Para que el código acceda a 100TB de datos)
resource "aws_iam_role" "ecs_task_role" {
  name = "seabook-ecs-task-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

# NUEVO: Política de permisos para Persistencia (S3 y DynamoDB)
resource "aws_iam_role_policy" "ecs_app_permissions" {
  name = "seabook-app-policy-${var.environment}"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Acceso a DynamoDB (RNF de Persistencia)
        Action   = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:UpdateItem", "dynamodb:Query"]
        Effect   = "Allow"
        Resource = "*" 
      },
      {
        # Acceso a S3 (Para los 100 TB de Tesis/Fotos)
        Action   = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"]
        Effect   = "Allow"
        Resource = ["arn:aws:s3:::seabook-media-*", "arn:aws:s3:::seabook-media-*/*"]
      }
    ]
  })
}

# --- 5. CIFRADO KMS (RNF 20 - Protección de PII) ---
resource "aws_kms_key" "seabook_data" {
  description             = "Llave para cifrar datos sensibles de SeaBook"
  deletion_window_in_days = 7
  enable_key_rotation     = true 

  tags = { Name = "seabook-kms-${var.environment}" }
}

# --- 6. IAM ROLE PARA DAX (Rendimiento < 300ms) ---
resource "aws_iam_role" "dax_role" {
  name = "seabook-dax-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "dax.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "dax_policy" {
  name = "seabook-dax-policy-${var.environment}"
  role = aws_iam_role.dax_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["dynamodb:DescribeTable", "dynamodb:GetItem", "dynamodb:Query", "dynamodb:Scan"]
      Effect   = "Allow"
      Resource = ["*"]
    }]
  })
}