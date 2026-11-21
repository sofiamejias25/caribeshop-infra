variable "subscription_id" {
  description = "ID de la suscripción de Azure"
  type        = string
}

variable "location" {
  description = "Región de despliegue"
  type        = string
  default     = "chilecentral"
}

variable "prefix" {
  description = "Prefijo de nombres de recursos"
  type        = string
  default     = "cs"
}
# Recibimos la clave publica SSH para acceder
# de forma segura a nuestras maquinas virtuales.
variable "clave_ssh_publica" {
  description = "Clave publica SSH para las instancias de CaribeShop"
  type        = string
}