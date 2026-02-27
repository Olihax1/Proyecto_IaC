# --- ACCESO A LA APLICACIÓN (RNF 17) ---
output "alb_dns_name" {
  description = "URL pública para acceder al portal de SeaBook (Carga < 1.5s vía CloudFront/ALB)"
  value       = module.compute.alb_dns_name
}

# --- INFORMACIÓN DE RED (RNF 18) ---
output "vpc_id" {
  description = "ID de la red principal Multi-AZ"
  value       = module.networking.vpc_id
}

output "private_subnet_ids" {
  description = "IDs de las subredes privadas donde residen los datos"
  value       = module.networking.private_subnet_ids
}

# --- ALMACENAMIENTO Y BASE DE DATOS (RNF 2, 14 y 15) ---


output "database_dax_endpoint" {
  description = "Endpoint del clúster DAX para búsquedas en microsegundos (Requerimiento 2)"
  value       = module.database.dax_cluster_endpoint
}

output "dynamodb_table_arn" {
  description = "ARN de la tabla con capacidad de hasta 100TB de datos (Requerimiento 14)"
  value       = module.database.table_arn
}

output "s3_bucket_media_id" {
  description = "Nombre del bucket S3 para los 100TB de tesis y fotos (RNF 15)"
  value       = module.database.s3_bucket_id
}

# --- PIPELINE DE CI/CD (RNF 22 - GITOPS) ---


output "pipeline_url" {
  description = "URL para monitorear despliegues Blue/Green con Cero Downtime"
  value       = "https://${var.aws_region}.console.aws.amazon.com/codesuite/codepipeline/pipelines/${module.cicd.codepipeline_id}/view?region=${var.aws_region}"
}

# --- SEGURIDAD Y PRIVACIDAD (RNF 20) ---
output "kms_key_arn" {
  description = "ARN de la llave KMS que cifra los datos de los 150,000 usuarios"
  value       = module.security.kms_key_arn
}

output "security_group_ecs_id" {
  description = "ID del Security Group de la aplicación para auditoría"
  value       = module.security.ecs_security_group_id
}

# --- ESTADO DEL SISTEMA ---
output "deployment_status" {
  value = "Infraestructura de SeaBook desplegada exitosamente bajo Atributos de Calidad UTP."
}
