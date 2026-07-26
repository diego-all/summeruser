provider "aws" {
  region  = "us-east-1"
  profile = "bold-free-tier"
}

# Aquí va la definición de tu secreto de Secrets Manager
resource "aws_secretsmanager_secret" "db_secret" {
  name = "SummerUserDbSecret"
}

resource "aws_secretsmanager_secret_version" "db_secret_val" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = "admin"
    password = "SuperPasswordSeguro123!"
    engine   = "mysql"
    host     = "midb.rds.amazonaws.com"
  })
}


# 1. Definir la política de IAM para permitir leer el secreto en Secrets Manager
resource "aws_iam_policy" "secrets_manager_read_policy" {
  name        = "SummerUserSecretsManagerReadPolicy"
  description = "Permite a la Lambda leer credenciales desde Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        # Aplica especificamente al secreto de la base de datos creado previamente
        Resource = aws_secretsmanager_secret.db_secret.arn
      }
    ]
  })
}

# 2. Adjuntar la política al Rol existente de la Lambda
# (Asegúrate de colocar el nombre real del recurso de tu aws_iam_role si fue creado en Terraform, 
#  o usa el nombre exacto de tu rol de Lambda "summerUser-role-f882kw0z")
resource "aws_iam_role_policy_attachment" "lambda_secrets_attach" {
  role       = "summerUser-role-f882kw0z" # Reemplaza por el nombre exacto de tu rol o aws_iam_role.tu_lambda_role.name
  policy_arn = aws_iam_policy.secrets_manager_read_policy.arn
}