variable "environment" {
  description = "Ambiente de trabajo (ej. dev, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC donde se desplegarán los Security Groups"
  type        = string
}

variable "vpc_cidr" {
  description = "Rango CIDR de la VPC para reglas de firewall interno"
  type        = string
}

variable "allowed_management_ips" {
  description = "Lista de IPs permitidas para administración (Requerimiento de Seguridad)"
  type        = list(string)
}

# --- NUEVAS VARIABLES PARA ATRIBUTOS DE CALIDAD ---

variable "ecs_cluster_name" {
  description = "Nombre del cluster para asociar políticas de IAM"
  type        = string
  default     = "seabook-cluster"
}

# Si estás usando EKS según el documento de Atributos de Calidad:
variable "eks_cluster_name" {
  description = "Nombre del cluster EKS para la orquestación de microservicios"
  type        = string
  default     = ""
}