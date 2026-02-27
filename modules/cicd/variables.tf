variable "environment" {
  description = "Entorno de despliegue (ej. dev, prod)"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Nombre del clúster de ECS donde corre SeaBook"
  type        = string
}

variable "ecs_service_name" {
  description = "Nombre del microservicio (ej. ms-reservas)"
  type        = string
}

# --- Variables para el Despliegue Blue/Green (RNF 22) ---
variable "alb_listener_arn" {
  description = "ARN del listener del balanceador para el tráfico productivo"
  type        = string
}

variable "target_group_blue_name" {
  description = "Nombre del Target Group principal (Blue)"
  type        = string
}

variable "target_group_green_name" {
  description = "Nombre del Target Group de reemplazo (Green)"
  type        = string
}

# --- Variables Adicionales Recomendadas ---
variable "ecr_repository_url" {
  description = "URL del repositorio ECR para subir la imagen del contenedor (RNF 23)"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC para configurar accesos seguros (RNF 18)"
  type        = string
}