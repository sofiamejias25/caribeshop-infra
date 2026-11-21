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