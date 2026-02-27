data "aws_availability_zones" "zonas" {}
data "aws_caller_identity" "actual" {}

locals {
  nombre    = var.prefijo
  usa_https = var.certificado_acm_arn != ""
  tags = {
    proyecto = local.nombre
  }
}