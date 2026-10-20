#!/usr/bin/env bash
# Obtiene un access token de Cognito para el usuario admin y lo imprime (para pegarlo en Postman).
# Ejecutar como root, dentro de la carpeta infrastructure:  sudo -s  ->  bash get_token.sh
# Lee client_id desde los outputs de Terraform y email/contraseña desde terraform.tfvars.
set -euo pipefail
 
PROFILE="bold-free-tier"
CLIENT_ID=$(terraform output -raw cognito_client_id)
EMAIL=$(grep -E '^\s*admin_user_email' terraform.tfvars | cut -d'"' -f2)
PASSWORD=$(grep -E '^\s*admin_user_password' terraform.tfvars | cut -d'"' -f2)
 
aws cognito-idp initiate-auth \
  --auth-flow USER_PASSWORD_AUTH \
  --client-id "$CLIENT_ID" \
  --auth-parameters "USERNAME=$EMAIL,PASSWORD=$PASSWORD" \
  --query 'AuthenticationResult.AccessToken' \
  --output text \
  --profile "$PROFILE"
 