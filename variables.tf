# --- 1. VARIABLES GENERALES ---
variable "aws_region" { 
  description = "Región de AWS para el despliegue"
  type        = string
  default     = "us-east-1" 
}

variable "environment" { 
  description = "Entorno de ejecución (dev/prod)"
  type        = string
  default     = "prod" # Cambiado a prod para activar escalado masivo
}

variable "project_name" {
  description = "Nombre del proyecto UTP"
  type        = string
  default     = "SeaBook"
}

# --- 2. VARIABLES DE NETWORKING (RNF 18) ---
variable "vpc_cidr" { 
  type    = string
  default = "10.0.0.0/16" 
}

variable "availability_zones" {
  description = "Zonas de disponibilidad para alta disponibilidad (Multi-AZ)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"] 
}

variable "public_subnets_cidr" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets_cidr" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}

variable "enable_nat_gateway" { 
  description = "Habilitar salida a internet para subredes privadas (parches)"
  type        = bool
  default     = true 
}

# --- 3. VARIABLES DE SEGURIDAD (RNF 20) ---
variable "allowed_management_ips" {
  description = "IPs autorizadas para administración (Acceso restringido)"
  type        = list(string)
  default     = ["190.0.0.1/32"] # Reemplaza con tu IP real
}

variable "certificate_arn" {
  description = "ARN del certificado SSL en ACM para HTTPS (Puerto 443)"
  type        = string
  default     = "arn:aws:acm:us-east-1:123456789012:certificate/tu-id-aqui"
}

# --- 4. VARIABLES DE ROLES E IDENTIDAD (Requeridas por main.tf) ---
# Estas variables permiten conectar los roles creados o existentes
variable "ecs_task_execution_role_arn" {
  description = "ARN del rol para que ECS descargue imágenes de ECR"
  type        = string
  default     = "" # Se puede dejar vacío si el módulo security lo genera
}

variable "ecs_task_role_arn" {
  description = "ARN del rol para que la App acceda a DynamoDB y S3"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "ARN de la llave KMS para cifrado de 100TB de datos"
  type        = string
  default     = ""
}

variable "dax_role_arn" {
  description = "ARN del rol para la aceleración DAX"
  type        = string
  default     = ""
}

# --- 5. VARIABLES DE ESCALABILIDAD (RNF 19) ---
variable "enable_multi_region" {
  description = "Activar réplica en otra región para desastres (DRP)"
  type        = bool
  default     = false
}
