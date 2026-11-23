
variable "location" {
  description = "Region de despliegue de CaribeShop"
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
}

variable "lb_id" {
  description = "ID del Load Balancer que se monitorea"
  type        = string
}

variable "alert_email" {
  description = "Correo que recibira las alertas"
  type        = string
}
