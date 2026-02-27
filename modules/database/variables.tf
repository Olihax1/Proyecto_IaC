variable "environment" {
  description = "Ambiente de trabajo (dev/prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC para configurar el Endpoint de DynamoDB (RNF 18)"
  type        = string
}

variable "private_subnet_ids" {
  description = "Subredes privadas para aislamiento de datos"
  type        = list(string)
}

variable "private_route_table_ids" {
  description = "IDs de las tablas de ruteo privadas para asociar el VPC Endpoint"
  type        = list(string)
}

variable "db_security_group_id" {
  description = "Grupo de seguridad que permite tráfico desde microservicios"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN de la llave KMS para cifrado de 100TB"
  type        = string
}

variable "dax_role_arn" {
  description = "Rol de IAM para que DAX acceda a DynamoDB"
  type        = string
}