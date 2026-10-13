# ========================================================================
# RECURSO S3 BUCKET (summer-images-<account_id>)
# ========================================================================

# Nombre único global: S3 exige que el nombre del bucket no exista en ninguna otra cuenta de AWS
data "aws_caller_identity" "current" {}

locals {
  bucket_name = "summer-images-${data.aws_caller_identity.current.account_id}"
}

# 1. Creación del Bucket S3
resource "aws_s3_bucket" "summer_images" {
  bucket        = local.bucket_name
  force_destroy = true
}

# 2. ACLs Deshabilitadas (BucketOwnerEnforced - Opción Recomendada por AWS)
resource "aws_s3_bucket_ownership_controls" "summer_images_ownership" {
  bucket = aws_s3_bucket.summer_images.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# 3. Bloqueo de Acceso Público Deshabilitado (Permite acceso público según la consola)
resource "aws_s3_bucket_public_access_block" "summer_images_public_access" {
  bucket = aws_s3_bucket.summer_images.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 4. Control de Versiones (Desactivado)
resource "aws_s3_bucket_versioning" "summer_images_versioning" {
  bucket = aws_s3_bucket.summer_images.id

  versioning_configuration {
    status = "Disabled"
  }
}

# 5. Cifrado Predeterminado (SSE-S3 con Clave de Bucket Habilitada)
resource "aws_s3_bucket_server_side_encryption_configuration" "summer_images_encryption" {
  bucket = aws_s3_bucket.summer_images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # SSE-S3: Claves administradas por Amazon S3
    }
    bucket_key_enabled = true # Clave de bucket: Habilitar
  }
}

# 6. Política del Bucket (Capítulo 60: lectura pública de objetos)
resource "aws_s3_bucket_policy" "summer_images_policy" {
  bucket     = aws_s3_bucket.summer_images.id
  depends_on = [aws_s3_bucket_public_access_block.summer_images_public_access] # Primero se abre el bloqueo público

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = ["s3:GetObject"] # Sin ListBucket: no se puede listar el contenido
      Resource  = ["${aws_s3_bucket.summer_images.arn}/*"]
    }]
  })
}

# Salida: nombre final del bucket (se usa como {folder} en la URL del API Gateway)
output "bucket_name" {
  value = aws_s3_bucket.summer_images.bucket
}