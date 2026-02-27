# --- Datos: Aurora + ElastiCache ---
resource "aws_db_subnet_group" "aurora" {
  name       = "${local.nombre}-aurora-subnets"
  subnet_ids = [for s in aws_subnet.privadas : s.id]
  tags       = local.tags
}

resource "aws_secretsmanager_secret" "db" {
  name = "${local.nombre}/aurora"
  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({ usuario = "seabook", clave = "***" })
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "${local.nombre}-aurora"
  engine                  = "aurora-postgresql"
  database_name           = "seabook"
  master_username         = "seabook"
  master_password         = "***"
  db_subnet_group_name    = aws_db_subnet_group.aurora.name
  vpc_security_group_ids  = [aws_security_group.aurora.id]
  backup_retention_period = 7
  storage_encrypted       = true

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 1.0
  }

  tags = local.tags
}

resource "aws_rds_cluster_instance" "writer" {
  identifier         = "${local.nombre}-aurora-writer"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.aurora.engine
  tags               = local.tags
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${local.nombre}-redis-subnets"
  subnet_ids = [for s in aws_subnet.privadas : s.id]
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = "${local.nombre}-redis"
  description                = "Redis SeaBook"
  engine                     = "redis"
  node_type                  = "cache.t3.micro"
  num_cache_clusters         = 1
  port                       = 6379
  subnet_group_name          = aws_elasticache_subnet_group.redis.name
  security_group_ids         = [aws_security_group.redis.id]
  automatic_failover_enabled = false
  tags                       = local.tags
}