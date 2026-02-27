variable "environment" {
  description = "Entorno (dev, qa, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC donde se desplegará el clúster"
  type        = string
}

# --- RED ---
variable "private_subnet_ids" {
  description = "Subredes para los contenedores (Aislamiento RNF 18)"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Subredes para el ALB"
  type        = list(string)
}

# --- SEGURIDAD Y ROLES ---
variable "certificate_arn" {
  description = "ARN del certificado SSL/TLS en ACM"
  type        = string
}

variable "alb_security_group_id" {
  type = string
}

variable "ecs_security_group_id" {
  type = string
}

variable "ecs_task_execution_role_arn" {
  description = "Rol para que ECS descargue imágenes de ECR y escriba en CloudWatch"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "Rol para que el código de la App acceda a DynamoDB/S3"
  type        = string
}

# --- NUEVAS VARIABLES RECOMENDADAS (Basadas en tu PDF) ---

variable "cpu_units" {
  description = "CPU para la tarea (ej. 256, 512, 1024)"
  default     = "256"
}

variable "memory_limit" {
  description = "Memoria para la tarea (ej. 512, 1024, 2048)"
  default     = "512"
}

variable "desired_count" {
  description = "Número de instancias base del microservicio"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Capacidad máxima para soportar los 15,000 clics simultáneos (RNF 19)"
  type        = number
  default     = 10
}