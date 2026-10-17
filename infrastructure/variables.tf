# Usuario administrador de la tienda (se inserta en la tabla users con User_Status = 0 al levantar la RDS)
# Defínelos en terraform.tfvars. Si admin_user_uuid queda vacío, no se inserta ningún usuario.
variable "admin_user_uuid" {
  description = "UUID del usuario de Cognito (claim 'username' del access token)"
  type        = string
  default     = ""
}

variable "admin_user_email" {
  description = "Email del usuario administrador"
  type        = string
  default     = ""
}
