# 1. User Pool (SummerUserPool)
resource "aws_cognito_user_pool" "pool" {
  name                     = "summer"
  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]

  # MFA desactivado (mfa = cognito.Mfa.OFF)
  mfa_configuration = "OFF"

  # Configuración del envío de correos con la infraestructura integrada de Cognito
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # Política de Contraseñas (8 caracteres, sin restricciones)
  password_policy {
    minimum_length                   = 8
    require_lowercase                = false
    require_numbers                  = false
    require_symbols                  = false
    require_uppercase                = false
    temporary_password_validity_days = 7
  }

  # Atributo Estándar Obligatorio y Modificable (Email)
  schema {
    attribute_data_type      = "String"
    name                     = "email"
    required                 = true
    mutable                  = true
    developer_only_attribute = false
  }

  # Recuperación de Cuenta mediante Email únicamente
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # ⬇️ DISPARADOR / TRIGGER DE LAMBDA (Post Confirmation)
  lambda_config {
    post_confirmation = aws_lambda_function.summer_user_lambda.arn
  }

  deletion_protection = "INACTIVE" # Equivalente a RemovalPolicy.DESTROY
}

# Permiso en IAM para que Cognito User Pool invoque la Lambda al confirmar usuario
resource "aws_lambda_permission" "allow_cognito_post_confirmation" {
  statement_id  = "AllowCognitoPostConfirmation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.summer_user_lambda.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.pool.arn
}

# 2. Dominio de Cognito (SummerDomain)
resource "aws_cognito_user_pool_domain" "main" {
  domain       = "summer-app-dev-unique"
  user_pool_id = aws_cognito_user_pool.pool.id
}

# 3. App Client de Cognito (SummerAppClient)
resource "aws_cognito_user_pool_client" "client" {
  name         = "summer"
  user_pool_id = aws_cognito_user_pool.pool.id

  generate_secret     = false
  explicit_auth_flows = ["ALLOW_USER_SRP_AUTH", "ALLOW_CUSTOM_AUTH"]

  # Duración de tokens
  refresh_token_validity = 30
  access_token_validity  = 1
  id_token_validity      = 1

  # Duración de la sesión de autenticación (3 minutos)
  auth_session_validity  = 3

  token_validity_units {
    refresh_token = "days"
    access_token  = "days"
    id_token      = "days"
  }

  # Seguridad y Prevención de errores de existencia de usuarios
  enable_token_revocation       = true
  prevent_user_existence_errors = "ENABLED"

  # Permisos de lectura/escritura de atributos
  read_attributes  = ["email", "email_verified"]
  write_attributes = ["email"]

  # Configuración de OAuth / Integration
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["openid", "email"]
  callback_urls                        = ["https://localhost:3000"]
  logout_urls                          = ["https://localhost:3000"]
  supported_identity_providers         = ["COGNITO"]
}

# ========================================================================
# 4. GRUPO DE IDENTIDADES FEDERADAS (IDENTITY POOL)
# ========================================================================
resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name               = "summer"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.client.id
    provider_name           = aws_cognito_user_pool.pool.endpoint
    server_side_token_check = false
  }
}

# Rol IAM para Usuarios Autenticados
resource "aws_iam_role" "authenticated_role" {
  name = "Cognito_summerAuth_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "cognito-identity.amazonaws.com"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.identity_pool.id
        }
        "ForAnyValue:StringLike" = {
          "cognito-identity.amazonaws.com:amr" = "authenticated"
        }
      }
    }]
  })
}

# Rol IAM para Usuarios No Autenticados
resource "aws_iam_role" "unauthenticated_role" {
  name = "Cognito_summerUnauth_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "cognito-identity.amazonaws.com"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.identity_pool.id
        }
        "ForAnyValue:StringLike" = {
          "cognito-identity.amazonaws.com:amr" = "unauthenticated"
        }
      }
    }]
  })
}

# Asociación de los Roles al Identity Pool
resource "aws_cognito_identity_pool_roles_attachment" "identity_pool_roles" {
  identity_pool_id = aws_cognito_identity_pool.identity_pool.id

  roles = {
    "authenticated"   = aws_iam_role.authenticated_role.arn
    "unauthenticated" = aws_iam_role.unauthenticated_role.arn
  }
}

# ========================================================================
# 5. COGNITO SYNC TRIGGER (DISPARADOR PARA IDENTITY POOL)
# ========================================================================
resource "aws_lambda_permission" "allow_cognito_identity_pool" {
  statement_id  = "AllowCognitoIdentityPoolSync"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.summer_user_lambda.function_name
  principal     = "cognito-sync.amazonaws.com"
  source_arn    = "${aws_cognito_identity_pool.identity_pool.arn}:*"
}