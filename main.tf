# 1. BLOQUE DE METADATOS
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 2. PROVEEDOR
provider "aws" {
  region  = var.aws_region
  profile = "Seabook"
}

# 3. MÓDULO 1: NETWORKING (Base de todo - Multi-AZ para Disponibilidad 24/7)

module "networking" {
  source = "./modules/networking"

  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones # Se recomienda us-east-1a, 1b para RNF 17
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  enable_nat_gateway   = var.enable_nat_gateway
}

# 4. MÓDULO 2: SEGURIDAD (Cifrado KMS y Roles IAM)
module "security" {
  source = "./modules/security"

  environment            = var.environment
  vpc_id                 = module.networking.vpc_id
  vpc_cidr               = module.networking.vpc_cidr_block
  allowed_management_ips = var.allowed_management_ips # Ej: ["200.0.0.1/32"]

  depends_on = [module.networking]
}

# 5. MÓDULO 3: COMPUTE (ECS Fargate - Orquestación para 15,000 usuarios)

module "compute" {
  source = "./modules/compute"

  environment                 = var.environment
  vpc_id                      = module.networking.vpc_id
  public_subnet_ids           = module.networking.public_subnet_ids
  private_subnet_ids          = module.networking.private_subnet_ids
  alb_security_group_id       = module.security.alb_security_group_id
  ecs_security_group_id       = module.security.ecs_security_group_id
  ecs_task_execution_role_arn = module.security.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.security.ecs_task_role_arn
  certificate_arn             = var.certificate_arn # TLS 1.3 para RNF 20

  depends_on = [module.security]
}

# 6. MÓDULO 4: DATABASE (DynamoDB + DAX para los 100TB de data)

module "database" {
  source = "./modules/database"

  environment             = var.environment
  vpc_id                  = module.networking.vpc_id
  private_subnet_ids      = module.networking.private_subnet_ids
  private_route_table_ids = module.networking.private_route_table_ids
  db_security_group_id    = module.security.db_security_group_id # Solo ECS llega a DB
  
  # Atributos de Calidad: Cifrado y Rendimiento
  kms_key_arn          = module.security.kms_key_arn  # Cifrado RNF 20
  dax_role_arn         = module.security.dax_role_arn # Búsquedas < 300ms RNF 2

  depends_on = [module.networking, module.security]
}

# 7. MÓDULO 5: CI/CD (Despliegue Blue/Green para Cero Downtime)
module "cicd" {
  source = "./modules/cicd"

  environment             = var.environment
  vpc_id                  = module.networking.vpc_id        # <--- Agrega esta línea
  ecr_repository_url      = "tu-cuenta-id.dkr.ecr.us-east-1.amazonaws.com/seabook-repo" # <--- Agrega esta línea
  ecs_cluster_name        = module.compute.ecs_cluster_name
  ecs_service_name        = module.compute.ecs_service_names["user"]
  alb_listener_arn        = module.compute.alb_listener_arn
  target_group_blue_name  = module.compute.target_group_names["user_blue"]
  target_group_green_name = module.compute.target_group_names["user_green"]

  depends_on = [module.compute]
}
