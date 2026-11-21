variable "key_vault_name" {
  description = "Nombre globalmente único del Key Vault."
  type        = string
}

variable "location" {
  description = "Región de Azure para el Key Vault."
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos de CaribeShop."
  type        = string
}

variable "operator_ip" {
  description = "IPv4 pública de la operadora autorizada en el firewall."
  type        = string
}

variable "subnet_app_id" {
  description = "ID de la subred de aplicación con el service endpoint Microsoft.KeyVault."
  type        = string
}