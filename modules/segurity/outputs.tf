# --- SECURITY GROUPS ---
output "alb_security_group_id" {
  description = "ID del SG para el Load Balancer (Acceso público)"
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "ID del SG para los Microservicios (Acceso desde ALB)"
  value       = aws_security_group.ecs.id
}

output "db_security_group_id" {
  description = "ID del SG para DynamoDB/DAX (Acceso privado)"
  value       = aws_security_group.db.id
}

# --- IAM ROLES PARA COMPUTO ---
output "ecs_task_execution_role_arn" {
  description = "Rol para que ECS descargue imágenes y suba logs a CloudWatch"
  value       = aws_iam_role.ecs_exec_role.arn
}

output "ecs_task_role_arn" {
  description = "Rol para que la aplicación acceda a S3 y DynamoDB"
  value       = aws_iam_role.ecs_task_role.arn
}

# --- NUEVOS: ATRIBUTOS DE CALIDAD (Seguridad y Rendimiento) ---
output "kms_key_arn" {
  description = "ARN de la llave para cifrar 100TB de datos en reposo" 
  value       = aws_kms_key.seabook_data.arn 
}

output "dax_role_arn" {
  description = "Rol necesario para que DAX acelere las búsquedas del catálogo" 
  value       = aws_iam_role.dax_role.arn
}