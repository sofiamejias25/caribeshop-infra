
# Usamos la misma version del proveedor Azure
# que tiene configurada el proyecto principal.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
