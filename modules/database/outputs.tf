# --- 1. DYNAMODB ---
output "table_name" {
  description = "Nombre de la tabla (necesario para las variables de entorno de la App)"
  value       = aws_dynamodb_table.this.name
}

output "table_arn" {
  description = "ARN de la tabla para políticas de IAM"
  value       = aws_dynamodb_table.this.arn
}

output "table_stream_arn" {
  description = "ARN del stream para la Capa de Analítica (AWS Glue)"
  value       = aws_dynamodb_table.this.stream_arn
}

# --- 2. ACELERACIÓN (DAX) ---
output "dax_cluster_endpoint" {
  description = "Endpoint para búsquedas ultra-rápidas (<300ms)"
  value       = aws_dax_cluster.this.cluster_address
}

# --- 3. ALMACENAMIENTO PESADO (S3 - RNF 100TB) ---
# CAMBIO CLAVE: Renombrado a s3_bucket_id para que el main.tf raíz lo encuentre
output "s3_bucket_id" {
  description = "Nombre del bucket para PDFs de tesis y fotos"
  value       = aws_s3_bucket.data_storage.id
}

output "s3_bucket_arn" {
  description = "ARN del bucket para permisos de IAM"
  value       = aws_s3_bucket.data_storage.arn
}