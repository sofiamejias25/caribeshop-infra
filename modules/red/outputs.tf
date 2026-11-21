
# Salidas del modulo de red de CaribeShop
# Aqui compartimos los datos de la red que necesitan
# los otros modulos para conectar sus recursos.

# Compartimos el identificador de la red virtual
output "vnet_id" {
  description = "Identificador de la red virtual de CaribeShop"
  value       = azurerm_virtual_network.principal.id
}

# Compartimos el identificador de la subred de la aplicacion
output "subnet_app_id" {
  description = "Identificador de la subred donde estaran las instancias"
  value       = azurerm_subnet.app.id
}

# Compartimos el identificador del grupo de seguridad
output "nsg_id" {
  description = "Identificador del grupo de seguridad de la aplicacion"
  value       = azurerm_network_security_group.app.id
}
