variable "region" {
  type = string
}

variable "perfil_aws" {
  type    = string
  default = "seabook"
}

variable "prefijo" {
  type    = string
  default = "seabook"
}

variable "cidr_vpc" {
  type    = string
  default = "10.10.0.0/16"
}

variable "subredes_publicas" {
  type    = list(string)
  default = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "subredes_privadas" {
  type    = list(string)
  default = ["10.10.11.0/24", "10.10.12.0/24"]
}

variable "certificado_acm_arn" {
  type        = string
  default     = ""
  description = "ARN ACM para TLS"
}

variable "dominio" {
  type        = string
  default     = ""
  description = "Dominio"
}

variable "presupuesto_usd_mensual" {
  type    = number
  default = 50
}