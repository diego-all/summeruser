# 1. (ELIMINADO) El secreto de Secrets Manager SummerUserDbSecret.
#    Ahora se reutiliza el parámetro aws_ssm_parameter.backend_db (/summer/db), definido en lambda_backend.tf

# 2. Rol de IAM para la Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "summerUser-role-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Política básica de CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# CAMBIO: permiso para leer el parámetro de Parameter Store (reemplaza la política de Secrets Manager)
resource "aws_iam_role_policy" "lambda_ssm_read" {
  name = "summeruser_ssm_read"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ssm:GetParameter"]
      Resource = aws_ssm_parameter.backend_db.arn
    }]
  })
}

# 3. Lambda de autenticación (post-confirmation de Cognito)
resource "aws_lambda_function" "summer_user_lambda" {
  filename         = "../function.zip"
  function_name    = "summerUser"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "bootstrap"
  runtime          = "provided.al2"
  source_code_hash = filebase64sha256("../function.zip")

  environment {
    variables = {
      # CAMBIO: ahora es el nombre del parámetro (/summer/db), no del secreto
      SecretName = aws_ssm_parameter.backend_db.name
    }
  }
}