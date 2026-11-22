resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg"
  location = var.location
}

# Creamos el modulo de red de CaribeShop
# Utilizamos el grupo de recursos principal para organizar
# todos los componentes de nuestra infraestructura.
module "red" {
  source = "./modules/red"

  ubicacion             = var.location
  nombre_grupo_recursos = azurerm_resource_group.main.name
}

# Creamos el modulo de computo de CaribeShop
# Conectamos las maquinas virtuales con la subred
# que configuramos anteriormente en nuestro modulo de red.
module "computo" {
  source = "./modules/computo"

  ubicacion             = var.location
  nombre_grupo_recursos = azurerm_resource_group.main.name

  # Conectamos las instancias a nuestra subred
  subnet_app_id = module.red.subnet_app_id

  # Configuramos el acceso seguro mediante SSH
  clave_ssh_publica = var.clave_ssh_publica

  # Preparamos la aplicacion para iniciar automaticamente
  # cuando Azure cree las maquinas virtuales.
  # Codificamos el archivo Python y posteriormente
  # la plantilla completa de cloud-init en base64.
  cloud_init = base64encode(templatefile("${path.module}/app/cloud-init.yaml", {
    app_py_base64 = filebase64("${path.module}/app/app.py")
    key_vault_uri = module.seguridad.key_vault_uri
    secret_name   = "db-password"
  }))
}

module "seguridad" {
  source = "./modules/seguridad"

  key_vault_name      = var.key_vault_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  operator_ip         = var.operator_ip
  subnet_app_id       = module.red.subnet_app_id
}

resource "azurerm_role_assignment" "vmss_key_vault_secrets_user" {
  scope                = module.seguridad.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.computo.vmss_principal_id
}


# E5 - Observabilidad centralizada de CaribeShop
module "observabilidad" {
  source = "./modules/observabilidad"

  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  lb_id       = module.computo.lb_id
  alert_email = var.alert_email
}


# Envio de eventos de Key Vault a Log Analytics
resource "azurerm_monitor_diagnostic_setting" "key_vault" {
  name                       = "cs-kv-diagnostics"
  target_resource_id         = module.seguridad.key_vault_id
  log_analytics_workspace_id = module.observabilidad.log_analytics_id

  enabled_log {
    category = "AuditEvent"
  }
}
