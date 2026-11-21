
# Variables del modulo de red de CaribeShop
# Aqui definimos los datos que necesitamos para configurar
# la red y conectar este modulo con el resto del proyecto.

# Definimos la region de Azure donde estaran los recursos
variable "ubicacion" {
  description = "Region donde desplegamos la infraestructura de CaribeShop"
  type        = string
  default     = "chilecentral"
}

# Recibimos el nombre del grupo de recursos creado desde Terraform
variable "nombre_grupo_recursos" {
  description = "Nombre del grupo de recursos de CaribeShop"
  type        = string
}
