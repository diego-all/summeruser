# ========================================================================
# LAMBDA PRINCIPAL DEL BACKEND (summer) - equivalente a "gambit" del curso
# ========================================================================

locals {
  backend_zip = "../../e-commerce-serverless-aws-golang/function.zip" # AJUSTA: ruta del function.zip del backend (relativa a la carpeta infrastructure)
}
# 1. Rol de ejecución (equivale a "Crear un nuevo rol desde plantillas de políticas de AWS")
resource "aws_iam_role" "summer_backend_role" {
  name = "summer-role-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Política Básica de CloudWatch Logs (la que la consola agrega por defecto al crear el rol)
resource "aws_iam_role_policy_attachment" "summer_backend_logs" {
  role       = aws_iam_role.summer_backend_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# (Opcional) Lectura del secreto de la base de datos: descomenta cuando el profesor lo asigne
# resource "aws_iam_role_policy_attachment" "summer_backend_secrets" {
#   role       = aws_iam_role.summer_backend_role.name
#   policy_arn = aws_iam_policy.secrets_manager_read_policy.arn
# }

# 2. Función Lambda (Crear desde cero, Go, x86_64)
resource "aws_lambda_function" "summer_backend_lambda" {
  filename         = local.backend_zip
  function_name    = "summer" # Cámbialo si prefieres otro nombre (el del profesor es "gambit")
  role             = aws_iam_role.summer_backend_role.arn
  runtime          = "provided.al2023" # El runtime "Go 1.x" de la consola ya fue retirado por AWS
  handler          = "main"            # Controlador del curso. Con provided.* se ignora: el binario debe llamarse bootstrap
  architectures    = ["x86_64"]
  memory_size      = 128 # Memoria = 128 MB
  timeout          = 30  # Tiempo de espera (rango permitido: 1 a 900 segundos)
  source_code_hash = filebase64sha256(local.backend_zip)

  # Almacenamiento efímero (/tmp)
  ephemeral_storage {
    size = 512
  }
}

# 3. URL de la función (equivale a "Habilitar URL de función" + configurar CORS)
resource "aws_lambda_function_url" "summer_backend_url" {
  function_name      = aws_lambda_function.summer_backend_lambda.function_name
  authorization_type = "NONE" # Pública, sin autenticación. Cambia a "AWS_IAM" para restringirla

  cors {
    allow_origins = ["*"]
    allow_methods = ["*"]
    allow_headers = ["content-type", "authorization"]
  }
}

# Permiso para que cualquiera pueda invocar la URL (la consola lo crea sola; en Terraform hay que declararlo)
resource "aws_lambda_permission" "summer_backend_url_public" {
  statement_id           = "FunctionURLAllowPublicAccess"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.summer_backend_lambda.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}

# Salida: URL pública de la Lambda
output "backend_url" {
  value = aws_lambda_function_url.summer_backend_url.function_url
}