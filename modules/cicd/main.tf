# --- 1. S3 BUCKET PARA ARTEFACTOS ---
resource "aws_s3_bucket" "artifacts" {
  bucket        = "seabook-artifacts-${var.environment}"
  force_destroy = true # Útil para entornos de desarrollo de la UTP
}

# --- 2. IAM ROLES (Separación de Funciones) ---
# Rol para CodePipeline
resource "aws_iam_role" "pipeline_role" {
  name = "seabook-pipeline-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "codepipeline.amazonaws.com" }
    }]
  })
}

# Política básica para que el pipeline use S3 y dispare CodeBuild
resource "aws_iam_role_policy" "pipeline_policy" {
  name = "seabook-pipeline-policy"
  role = aws_iam_role.pipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:GetObject", "s3:PutObject", "codebuild:StartBuild", "codebuild:BatchGetBuilds"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# --- 3. CODEBUILD PARA DOCKER (RNF 23: Modularidad) ---
resource "aws_codebuild_project" "app_build" {
  name          = "seabook-build-${var.environment}"
  service_role  = aws_iam_role.pipeline_role.arn # Nota: Se recomienda un rol dedicado para Build

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true # ¡Obligatorio para Docker! [cite: 389]
    
    environment_variable {
      name  = "REPOSITORY_URI"
      value = var.ecr_repository_url # Deberás pasar esta variable desde tu módulo de security o database
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}

# --- 4. CODEPIPELINE (RNF 22: Blue/Green Deployment) ---
resource "aws_codepipeline" "this" {
  name     = "seabook-pipeline-${var.environment}"
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub" # Recomendado usar 'CodeStarSourceConnection' para GitHub moderno
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        Owner  = "tu-usuario-utp"
        Repo   = "seabook-app"
        Branch = "main"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = aws_codebuild_project.app_build.name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS" # [cite: 381]
      version         = "1"
      input_artifacts = ["build_output"]
      configuration = {
        ApplicationName                = "AppECS-${var.environment}"
        DeploymentGroupName            = "DGESC-${var.environment}"
        TaskDefinitionTemplateArtifact = "build_output"
        AppSpecTemplateArtifact        = "build_output"
        # Estos archivos (appspec.yaml y taskdef.json) deben generarse en el Build
      }
    }
  }
}