# ========================================================================
# 1. API GATEWAY REST (SummerS3)
# ========================================================================
resource "aws_api_gateway_rest_api" "summer_s3_api" {
  name        = "SummerS3"
  description = "API Gateway con integración directa a S3"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# ========================================================================
# 2. AUTORIZADOR DE COGNITO
# ========================================================================
resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name          = "Cognito"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.summer_s3_api.id
  provider_arns = [aws_cognito_user_pool.pool.arn]
  identity_source = "method.request.header.Authorization"
}

# ========================================================================
# 3. RECURSO /{folder} CON CORS
# ========================================================================
resource "aws_api_gateway_resource" "folder" {
  rest_api_id = aws_api_gateway_rest_api.summer_s3_api.id
  parent_id   = aws_api_gateway_rest_api.summer_s3_api.root_resource_id
  path_part   = "{folder}"
}

# Habilitar CORS en /{folder} (Creación de método OPTIONS)
resource "aws_api_gateway_method" "folder_options" {
  rest_api_id   = aws_api_gateway_rest_api.summer_s3_api.id
  resource_id   = aws_api_gateway_resource.folder.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "folder_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.summer_s3_api.id
  resource_id = aws_api_gateway_resource.folder.id
  http_method = aws_api_gateway_method.folder_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "folder_options_200" {
  rest_api_id = aws_api_gateway_rest_api.summer_s3_api.id
  resource_id = aws_api_gateway_resource.folder.id
  http_method = aws_api_gateway_method.folder_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "folder_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.summer_s3_api.id
  resource_id = aws_api_gateway_resource.folder.id
  http_method = aws_api_gateway_method.folder_options.http_method
  status_code = aws_api_gateway_method_response.folder_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# ========================================================================
# 4. RECURSO /{folder}/{object} CON CORS
# ========================================================================
resource "aws_api_gateway_resource" "object" {
  rest_api_id = aws_api_gateway_rest_api.summer_s3_api.id
  parent_id   = aws_api_gateway_resource.folder.id
  path_part   = "{object}"
}

# Habilitar CORS en /{folder}/{object} (Creación de método OPTIONS)
resource "aws_api_gateway_method" "object_options" {
  rest_api_id   = aws_api_gateway_rest_api.summer_s3_api.id
  resource_id   = aws_api_gateway_resource.object.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "object_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.summer_s3_api.id
  resource_id = aws_api_gateway_resource.object.id
  http_method = aws_api_gateway_method.object_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "object_options_200" {
  rest_api_id = aws_api_gateway_rest_api.summer_s3_api.id
  resource_id = aws_api_gateway_resource.object.id
  http_method = aws_api_gateway_method.object_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "object_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.summer_s3_api.id
  resource_id = aws_api_gateway_resource.object.id
  http_method = aws_api_gateway_method.object_options.http_method
  status_code = aws_api_gateway_method_response.object_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# ========================================================================
# 5. MÉTODO PUT EN /{folder}/{object}
# ========================================================================
resource "aws_api_gateway_method" "put_object" {
  rest_api_id          = aws_api_gateway_rest_api.summer_s3_api.id
  resource_id          = aws_api_gateway_resource.object.id
  http_method          = "PUT"
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = aws_api_gateway_authorizer.cognito_authorizer.id
  api_key_required     = false
  authorization_scopes = ["openid"]

  request_parameters = {
    "method.request.path.folder" = true
    "method.request.path.object" = true
  }
}

# Integración con el servicio S3 mediante sustitución de rutas ({bucket}/{key})
resource "aws_api_gateway_integration" "s3_put_integration" {
  rest_api_id             = aws_api_gateway_rest_api.summer_s3_api.id
  resource_id             = aws_api_gateway_resource.object.id
  http_method             = aws_api_gateway_method.put_object.http_method
  integration_http_method = "PUT"
  type                    = "AWS"
  
  # Endpoint directo de S3 usando la región us-east-1
  uri                     = "arn:aws:apigateway:us-east-1:s3:path/{bucket}/{key}"
  credentials             = aws_iam_role.api_gateway_role.arn
  passthrough_behavior    = "WHEN_NO_MATCH"

  request_parameters = {
    "integration.request.path.bucket" = "method.request.path.folder"
    "integration.request.path.key"    = "method.request.path.object"
  }
}

# Respuesta de Método 200
resource "aws_api_gateway_method_response" "put_200" {
  rest_api_id = aws_api_gateway_rest_api.summer_s3_api.id
  resource_id = aws_api_gateway_resource.object.id
  http_method = aws_api_gateway_method.put_object.http_method
  status_code = "200"
}

# Respuesta de Integración
resource "aws_api_gateway_integration_response" "put_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.summer_s3_api.id
  resource_id = aws_api_gateway_resource.object.id
  http_method = aws_api_gateway_method.put_object.http_method
  status_code = aws_api_gateway_method_response.put_200.status_code

  depends_on = [aws_api_gateway_integration.s3_put_integration]
}