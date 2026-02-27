# --- 1. PERSISTENCIA A GRAN ESCALA (DYNAMODB) ---
# Diseñado para soportar de 2TB a 100TB de data
resource "aws_dynamodb_table" "this" {
  name           = "seabook-data-${var.environment}"
  billing_mode   = "PAY_PER_REQUEST" # Escalabilidad automática para picos de tráfico
  hash_key       = "PK" # Partición de datos distribuida
  range_key      = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  # Requerimiento 15: Point-in-Time Recovery (RPO 5 min)
  point_in_time_recovery {
    enabled = true
  }

  # Requerimiento 20: Cifrado en reposo para protección de PII
  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  # NUEVO: Stream para la Capa de Analítica (Página 19 del PDF)
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  tags = {
    Name        = "seabook-dynamodb-table"
    Environment = var.environment
  }
}

# --- 2. ACELERACIÓN DE LECTURA (DAX) ---
# Requerimiento 2: Búsquedas en menos de 300 ms 
resource "aws_dax_subnet_group" "this" {
  name       = "seabook-dax-subnets-${var.environment}"
  subnet_ids = var.private_subnet_ids # Aislamiento en red privada
}

resource "aws_dax_cluster" "this" {
  cluster_name       = "seabook-dax-cluster-${var.environment}"
  iam_role_arn       = var.dax_role_arn
  node_type          = "dax.t3.small"
  replication_factor = 3 # Despliegue en 3 zonas (Multi-AZ) para 99.99% uptime
  
  subnet_group_name  = aws_dax_subnet_group.this.name
  security_group_ids = [var.db_security_group_id]

  # Cifrado de la caché para cumplimiento normativo
  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = "seabook-dax-cache"
    Environment = var.environment
  }
}

# --- 3. ALMACENAMIENTO DE ARCHIVOS PESADOS (S3) ---
# Requerimiento: Hasta 100 TB de fotos y PDFs de tesis
resource "aws_s3_bucket" "data_storage" {
  bucket = "seabook-media-storage-${var.environment}"
  
  # Evita el borrado accidental de documentos de tesis
  lifecycle {
    prevent_destroy = true
  }
}

# Versionado para cumplir con el RNF de Recuperabilidad
resource "aws_s3_bucket_versioning" "storage_versioning" {
  bucket = aws_s3_bucket.data_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Regla de ciclo de vida para optimizar costos (100 TB es mucha data)

resource "aws_s3_bucket_lifecycle_configuration" "storage_lifecycle" {
  bucket = aws_s3_bucket.data_storage.id

  rule {
    id     = "archive-old-files"
    status = "Enabled"

    # SOLUCIÓN AL WARNING: Se añade un filtro vacío para aplicar a todo el bucket
    filter {}

    transition {
      days          = 90
      storage_class = "GLACIER" # Mueve tesis antiguas a almacenamiento barato
    }
  }
}

# --- 4. SEGURIDAD: VPC ENDPOINT (Página 20 del PDF) ---
# Esto garantiza que la base de datos no salga a internet (RNF 18)
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-east-1.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.private_route_table_ids
}