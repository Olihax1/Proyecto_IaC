output "codepipeline_arn" {
  description = "El ARN del pipeline de CI/CD para SeaBook" 
  value       = aws_codepipeline.this.arn
}

output "codepipeline_id" {
  description = "El ID del pipeline"
  value       = aws_codepipeline.this.id
}

output "artifact_bucket_name" {
  description = "El nombre del bucket de S3 para artefactos"
  value       = aws_s3_bucket.artifacts.id
}

# Salida adicional recomendada para observabilidad
output "codebuild_project_name" {
  description = "Nombre del proyecto de construcción para monitoreo" 
  value       = aws_codebuild_project.app_build.name
}