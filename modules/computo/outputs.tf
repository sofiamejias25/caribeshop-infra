
# Salidas del modulo de computo de CaribeShop
# Aqui compartimos los datos que necesitan los otros modulos
# para conectar sus recursos con nuestra infraestructura.

# Compartimos el identificador del conjunto de maquinas virtuales
output "vmss_id" {
  description = "Identificador del VM Scale Set de CaribeShop"
  value       = azurerm_linux_virtual_machine_scale_set.app.id
}

# Compartimos la identidad administrada de las maquinas
# para que Sofia configure los permisos de acceso a Key Vault
output "vmss_principal_id" {
  description = "Identificador de la identidad administrada del VMSS"
  value       = azurerm_linux_virtual_machine_scale_set.app.identity[0].principal_id
}

# Compartimos la IP publica del balanceador
# para acceder a la aplicacion y realizar las pruebas de carga
output "lb_public_ip" {
  description = "Direccion IP publica del balanceador de CaribeShop"
  value       = azurerm_public_ip.principal.ip_address
}

# Compartimos el identificador del balanceador de carga
output "lb_id" {
  description = "Identificador del balanceador de carga"
  value       = azurerm_lb.principal.id
}

# Compartimos el identificador de la sonda de salud
# para consultar su funcionamiento durante las pruebas
output "health_probe_id" {
  description = "Identificador de la sonda de salud del balanceador"
  value       = azurerm_lb_probe.app.id
}

# Compartimos el identificador del escalamiento automatico
# para consultar su configuracion y revisar las metricas
output "autoscale_id" {
  description = "Identificador de la configuracion de autoscale"
  value       = azurerm_monitor_autoscale_setting.app.id
}
