# --- Data Pipeline: S3 Data Lake + Glue + Athena + Glacier ---
resource "aws_s3_bucket" "datalake" {
  bucket = "${local.nombre}-datalake-${data.aws_caller_identity.actual.account_id}"
  tags   = local.tags
}

resource "aws_s3_bucket" "archivo" {
  bucket = "${local.nombre}-archivo-${data.aws_caller_identity.actual.account_id}"
  tags   = local.tags
}

resource "aws_s3_bucket_lifecycle_configuration" "archivo" {
  bucket = aws_s3_bucket.archivo.id
  rule {
    id     = "mover-a-glacier"
    status = "Enabled"
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
}

resource "aws_glue_catalog_database" "glue" {
  name = "${local.nombre}_glue"
}

resource "aws_athena_workgroup" "athena" {
  name = "${local.nombre}-athena"
  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.datalake.bucket}/athena/"
    }
  }
}

# --- AWS Backup ---
resource "aws_backup_vault" "vault" {
  name = "${local.nombre}-vault"
  tags = local.tags
}

resource "aws_backup_plan" "plan" {
  name = "${local.nombre}-plan"
  rule {
    rule_name         = "diario"
    target_vault_name = aws_backup_vault.vault.name
    schedule          = "cron(0 5 * * ? *)"
  }
}

# --- Budgets ---
resource "aws_budgets_budget" "mensual" {
  name         = "${local.nombre}-presupuesto"
  budget_type  = "COST"
  limit_amount = var.presupuesto_usd_mensual
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
}