# ========================================================================
# ROL DE IAM Y POLÍTICAS DE PERMISOS PARA API GATEWAY
# ========================================================================

# 1. Rol de IAM que asume el servicio de API Gateway
resource "aws_iam_role" "api_gateway_role" {
  name = "summer-api-gateway-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

# 2. Política administrada por AWS para CloudWatch Logs (AmazonAPIGatewayPushToCloudWatchLogs)
resource "aws_iam_role_policy_attachment" "api_gateway_cw_logs" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# 3. Política Insertada (Inline) para Operaciones en S3 (summer_s3)
resource "aws_iam_role_policy" "summer_s3" {
  name = "summer_s3"
  role = aws_iam_role.api_gateway_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "VisualEditor0"
        Effect   = "Allow"
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.summer_images.arn}/*" # Vinculado al bucket 'summer-images'
      },
      {
        Sid      = "VisualEditor1"
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.summer_images.arn}/*" # Vinculado al bucket 'summer-images'
      }
    ]
  })
}

# 4. Política Insertada (Inline) para Cognito Identity (summerCognito)
resource "aws_iam_role_policy" "summer_cognito" {
  name = "summerCognito"
  role = aws_iam_role.api_gateway_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "VisualEditor0"
        Effect = "Allow"
        Action = [
          "cognito-identity:GetId",
          "cognito-identity:SetPrincipalTagAttributeMap",
          "cognito-identity:SetIdentityPoolRoles",
          "cognito-identity:ListIdentityPools",
          "cognito-identity:CreateIdentityPool",
          "cognito-identity:UnlinkIdentity",
          "cognito-identity:DeleteIdentities",
          "cognito-identity:GetOpenIdToken",
          "cognito-identity:DescribeIdentity",
          "cognito-identity:GetCredentialsForIdentity"
        ]
        Resource = "*"
      },
      {
        Sid      = "VisualEditor1"
        Effect   = "Allow"
        Action   = "cognito-identity:*"
        Resource = aws_cognito_identity_pool.identity_pool.arn # Vinculado al Identity Pool de cognito.tf
      }
    ]
  })
}