# Usuario administrador de la tienda (se inserta en la tabla users con User_Status = 0 al levantar la RDS)
# Defínelos en terraform.tfvars. Si admin_user_uuid queda vacío, no se inserta ningún usuario.
# variable "admin_user_uuid" {
#   description = "UUID del usuario de Cognito (claim 'username' del access token)"
#   type        = string
#   default     = ""
# }

# variable "admin_user_email" {
#   description = "Email del usuario administrador"
#   type        = string
#   default     = ""
# }


# Usuario administrador de la tienda (se crea en Cognito y se inserta en la tabla users con User_Status = 0 al levantar la RDS)
# Defínelos en terraform.tfvars. Si admin_user_email queda vacío, no se crea ningún admin.
# CAMBIO: se elimina admin_user_uuid (el sub lo genera Cognito y Terraform lo toma de aws_cognito_user.admin).
variable "admin_user_email" {
  description = "Email del usuario administrador (también es su username de login en Cognito)"
  type        = string
  default     = ""
}

# CAMBIO: contraseña permanente del admin en Cognito. Va en terraform.tfvars (no lo subas a git).
variable "admin_user_password" {
  description = "Contraseña del usuario administrador en Cognito (mínimo 8 caracteres)"
  type        = string
  default     = ""
  sensitive   = true
}
