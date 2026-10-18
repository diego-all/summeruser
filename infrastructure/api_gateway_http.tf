# ========================================================================
# API GATEWAY HTTP (lambda_backend) - equivalente a "gambit" del curso
# ========================================================================

# 1. API HTTP (API Gateway v2). Es distinta de la REST "SummerS3": el tipo se elige al crearla
resource "aws_apigatewayv2_api" "backend_http_api" {
  name          = "lambda_backend"
  protocol_type = "HTTP"

  # CORS del API Gateway (asteriscos, como en la lección 66)
  cors_configuration {
    allow_origins     = ["*"]
    allow_headers     = ["*"]
    allow_methods     = ["*"]
    expose_headers    = ["*"]
    max_age           = 0
    allow_credentials = false
  }
}

# 2. Integración de tipo Lambda, versión 2.0 (formato recomendado para APIs HTTP)
resource "aws_apigatewayv2_integration" "backend_lambda" {
  api_id                 = aws_apigatewayv2_api.backend_http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.summer_backend_lambda.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# 3. Ruta: cualquier método sobre /summer apunta a la integración (en el curso es ANY /gambit)
# CAMBIO (lección 75): se elimina la ruta ANY /summer y se crea la ruta principal POST /summer/category
# (en el curso es POST /gambit/category). Se le asocia el autorizador (sección 6) y la integración (sección 2).
resource "aws_apigatewayv2_route" "backend_category_post" {
  api_id    = aws_apigatewayv2_api.backend_http_api.id
  route_key = "POST /summer/category"
  target    = "integrations/${aws_apigatewayv2_integration.backend_lambda.id}"

  # CAMBIO: la ruta queda protegida con el autorizador JWT "summer_cognito" (el curso usa "gambit_cognito").
  # Sin token de Cognito en el header Authorization la ruta responderá 401. No se configuran ámbitos.
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.backend_cognito.id
}

# CAMBIO (lección 79): ruta PUT /summer/category/{id} (en el curso es PUT /gambit/category/{id}).
# Igual que en la consola: se coloca la ruta completa SIN la etapa (la etapa "summer" ya la agrega el stage).
# {id} es un parámetro de ruta: API Gateway lo acepta como parte de la URL (ej. /summer/category/5) y lo entrega
# a la Lambda en request.PathParameters["id"]. Sin las llaves, la ruta no coincidiría y API Gateway respondería 404.
# Usa la misma integración (Lambda summer) y el mismo autorizador JWT summer_cognito que el POST.
resource "aws_apigatewayv2_route" "backend_category_put" {
  api_id    = aws_apigatewayv2_api.backend_http_api.id
  route_key = "PUT /summer/category/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.backend_lambda.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.backend_cognito.id
}

# CAMBIO (lección 80): ruta DELETE /summer/category/{id} (en el curso es DELETE /gambit/category/{id}).
# Misma mecánica que el PUT: ruta completa sin la etapa, {id} como parámetro de ruta (llega a la Lambda en
# request.PathParameters["id"]), la misma integración (Lambda summer) y el mismo autorizador JWT summer_cognito.
# El body no se usa: el backend solo necesita el id de la URL y el usuario del token (debe ser admin).
resource "aws_apigatewayv2_route" "backend_category_delete" {
  api_id    = aws_apigatewayv2_api.backend_http_api.id
  route_key = "DELETE /summer/category/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.backend_lambda.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.backend_cognito.id
}

# CAMBIO (lección 81): ruta GET /summer/category (en el curso es GET /gambit/category).
# Es una de las dos únicas rutas SIN autorizador (la otra será GET /summer/product): el listado de categorías es público,
# y en handlers.go validoAuthorization ya deja pasar path "category" + GET sin exigir token.
# Por eso no se configura authorization_type ni authorizer_id (por defecto "NONE"): en la consola equivale a no tocar
# la pestaña de autorización. Solo se asocia la integración (la misma Lambda summer).
# Los filtros del GET (categId, slug) llegan como query string, no hacen falta rutas adicionales.
resource "aws_apigatewayv2_route" "backend_category_get" {
  api_id             = aws_apigatewayv2_api.backend_http_api.id
  route_key          = "GET /summer/category"
  target             = "integrations/${aws_apigatewayv2_integration.backend_lambda.id}"
  authorization_type = "NONE"
}

# CAMBIO (lección 89): dominio de productos. Ruta POST /summer/product (en el curso es POST /gambit/product).
# Es el INSERT de productos: lleva autorizador JWT "summer_cognito" porque solo un admin puede crear productos
# (el router llama a bd.UserIsAdmin con el usuario del token). Ruta completa SIN la etapa, y misma integración
# (Lambda summer) que las rutas de category. No lleva {id}: el producto se crea con los datos del body.
# Con UrlPrefix "/summer/summer/" la ruta llega a la Lambda como path "product" y el router entra por path[0:4] == "prod".
resource "aws_apigatewayv2_route" "backend_product_post" {
  api_id    = aws_apigatewayv2_api.backend_http_api.id
  route_key = "POST /summer/product"
  target    = "integrations/${aws_apigatewayv2_integration.backend_lambda.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.backend_cognito.id
}

# CAMBIO (lección 90): ruta PUT /summer/product/{id} (en el curso es PUT /gambit/product/{id}).
# Es el UPDATE de productos. Igual que PUT /summer/category/{id}: ruta completa SIN la etapa, {id} como parámetro de ruta
# (llega a la Lambda en request.PathParameters["id"] y handlers.go lo convierte a int), la misma integración
# (Lambda summer) y el mismo autorizador JWT summer_cognito, porque solo un admin puede modificar productos.
# Con UrlPrefix "/summer/summer/" la ruta llega a la Lambda como "product/5" y el router entra por path[0:4] == "prod".
resource "aws_apigatewayv2_route" "backend_product_put" {
  api_id    = aws_apigatewayv2_api.backend_http_api.id
  route_key = "PUT /summer/product/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.backend_lambda.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.backend_cognito.id
}

# CAMBIO (lección 93): ruta DELETE /summer/product/{id} (en el curso es DELETE /gambit/product/{id}).
# Es el DELETE de productos. Igual que DELETE /summer/category/{id}: ruta completa SIN la etapa, {id} como parámetro de ruta
# (llega a la Lambda en request.PathParameters["id"]), la misma integración (Lambda summer) y el mismo autorizador JWT
# summer_cognito, porque solo un admin puede borrar productos. No usa body: solo el id de la URL y el usuario del token.
# Con UrlPrefix "/summer/summer/" la ruta llega a la Lambda como "product/5" y el router entra por path[0:4] == "prod".
resource "aws_apigatewayv2_route" "backend_product_delete" {
  api_id    = aws_apigatewayv2_api.backend_http_api.id
  route_key = "DELETE /summer/product/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.backend_lambda.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.backend_cognito.id
}

# 4. Etapa (sin $default). Con auto_deploy, cada cambio se publica solo
# CAMBIO: la etapa ahora se llama "summer" (en el curso es "gambit") en lugar de "dev".
# La implementación automática queda habilitada (por ahora sirve ya que no estamos en producción)
resource "aws_apigatewayv2_stage" "backend_summer" {
  api_id      = aws_apigatewayv2_api.backend_http_api.id
  name        = "summer"
  auto_deploy = true
}

# 5. Permiso para que API Gateway invoque la Lambda (la consola lo crea sola; en Terraform hay que declararlo)
resource "aws_lambda_permission" "backend_apigw" {
  statement_id  = "AllowExecutionFromAPIGatewayHTTP"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.summer_backend_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.backend_http_api.execution_arn}/*/*"
}

# 6. Autorizador JWT contra Cognito (menú Authorization > Administrar autorizadores > Crear)
# El docente lo llama "gambit_cognito"; aquí se llama "summer_cognito".
# Valida el token que se envía en el header Authorization de las rutas.
# (Solo se va a usar este autorizador)
resource "aws_apigatewayv2_authorizer" "backend_cognito" {
  api_id          = aws_apigatewayv2_api.backend_http_api.id
  name            = "summer_cognito"
  authorizer_type = "JWT"

  # Origen de identidad: queda igual (por defecto)
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    # URL del emisor: https://cognito-idp.us-east-1.amazonaws.com/{id del grupo de usuarios}
    # El atributo "endpoint" del User Pool ya devuelve "cognito-idp.us-east-1.amazonaws.com/{id}"
    issuer = "https://${aws_cognito_user_pool.pool.endpoint}"

    # Agregar público: ID de cliente de la aplicación de Cognito
    # (pestaña "Integración de aplicaciones" > ID de cliente)
    audience = [aws_cognito_user_pool_client.client.id]
  }
}

# URL base de la API HTTP (para Postman, Insomnia y Next.js)
# CAMBIO: apunta a la etapa "summer"; la URL queda como https://<id>.execute-api.us-east-1.amazonaws.com/summer
output "backend_http_url" {
  value = aws_apigatewayv2_stage.backend_summer.invoke_url
}

# ID del autorizador (se usa al asociarlo a las rutas)
output "backend_authorizer_id" {
  value = aws_apigatewayv2_authorizer.backend_cognito.id
}
