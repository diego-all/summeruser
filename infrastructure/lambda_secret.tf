# 1. Secreto en Secrets Manager apuntando a la RDS
resource "aws_secretsmanager_secret" "db_secret" {
  name                    = "SummerUserDbSecret"
  recovery_window_in_days = 0 # Equivalente a RemovalPolicy.DESTROY para forzar eliminación inmediata si se destruye
}

resource "aws_secretsmanager_secret_version" "db_secret_val" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username            = aws_db_instance.summer_rds.username
    password            = aws_db_instance.summer_rds.password
    engine              = "mysql"
    host                = aws_db_instance.summer_rds.address
    port                = 3306
    dbCLusterIdentifier = "summer"
  })
}

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

# Política Básica de CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Política para Lectura del Secreto
resource "aws_iam_policy" "secrets_manager_read_policy" {
  name        = "SummerUserSecretsManagerReadPolicy"
  description = "Permite a la Lambda leer credenciales desde Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = aws_secretsmanager_secret.db_secret.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_secrets_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.secrets_manager_read_policy.arn
}

# 3. Recurso de la Lambda (Ya subiste el ZIP previamente)
resource "aws_lambda_function" "summer_user_lambda" {
  filename         = "../function.zip"
  function_name    = "summerUser"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "bootstrap"
  runtime          = "provided.al2"
  source_code_hash = filebase64sha256("../function.zip")

  environment {
    variables = {
      SecretName = aws_secretsmanager_secret.db_secret.name
    }
  }
}