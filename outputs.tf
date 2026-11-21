
# Salidas principales de la infraestructura CaribeShop

# Compartimos la IP publica del balanceador
# para acceder a nuestra aplicacion desde Internet.
output "lb_public_ip" {
  description = "IP publica del balanceador de CaribeShop"
  value       = module.computo.lb_public_ip
}

# Compartimos el identificador del conjunto de maquinas virtuales.
output "vmss_id" {
  description = "Identificador del VM Scale Set"
  value       = module.computo.vmss_id
}

# Compartimos la identidad administrada del VMSS.
# Sofia utilizara este identificador para configurar
# los permisos de acceso a nuestro Key Vault.
output "vmss_principal_id" {
  description = "Identidad administrada del VMSS"
  value       = module.computo.vmss_principal_id
}

# Compartimos el identificador del balanceador.
output "lb_id" {
  description = "Identificador del Load Balancer"
  value       = module.computo.lb_id
}

# Compartimos la sonda de salud del balanceador.
output "health_probe_id" {
  description = "Identificador de la sonda de salud"
  value       = module.computo.health_probe_id
}

# Compartimos la configuracion de escalamiento automatico.
output "autoscale_id" {
  description = "Identificador de autoscaling"
  value       = module.computo.autoscale_id
}

# Compartimos los identificadores de nuestra red.
output "vnet_id" {
  description = "Identificador de la red virtual"
  value       = module.red.vnet_id
}

output "subnet_app_id" {
  description = "Identificador de la subred de la aplicacion"
  value       = module.red.subnet_app_id
}

output "nsg_id" {
  description = "Identificador del grupo de seguridad"
  value       = module.red.nsg_id
}
