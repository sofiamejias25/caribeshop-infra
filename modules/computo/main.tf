
# Infraestructura de computo de CaribeShop
# Aqui configuramos el balanceador de carga y las maquinas
# virtuales que van a ejecutar nuestra aplicacion.

# Creamos una IP publica para recibir las peticiones de los usuarios
# La distribuimos entre las zonas para mejorar la disponibilidad
resource "azurerm_public_ip" "principal" {
  name                = "cs-pip-lb"
  location            = var.ubicacion
  resource_group_name = var.nombre_grupo_recursos
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zonas
}

# Creamos el balanceador que distribuye el trafico de la aplicacion
resource "azurerm_lb" "principal" {
  name                = "cs-lb-app"
  location            = var.ubicacion
  resource_group_name = var.nombre_grupo_recursos
  sku                 = "Standard"

  # Asociamos la IP publica al balanceador
  frontend_ip_configuration {
    name                 = "frontend-http"
    public_ip_address_id = azurerm_public_ip.principal.id
  }
}

# Creamos el grupo donde se conectaran las instancias del VMSS
resource "azurerm_lb_backend_address_pool" "app" {
  name            = "cs-backend-app"
  loadbalancer_id = azurerm_lb.principal.id
}

# Configuramos la sonda para comprobar si las instancias responden
# Utilizamos el endpoint /health que prepara Sofia en la aplicacion
resource "azurerm_lb_probe" "app" {
  name                = "cs-probe-health"
  loadbalancer_id     = azurerm_lb.principal.id
  protocol            = "Http"
  port                = 80
  request_path        = "/health"
  interval_in_seconds = 5
  number_of_probes    = 2
}

# Creamos la regla para enviar las peticiones HTTP
# solamente a las instancias que esten funcionando
resource "azurerm_lb_rule" "http" {
  name                           = "cs-regla-http"
  loadbalancer_id                = azurerm_lb.principal.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend-http"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app.id]
  probe_id                       = azurerm_lb_probe.app.id
}



# Creamos el conjunto de maquinas virtuales de CaribeShop
# Las distribuimos entre varias zonas para mejorar la disponibilidad
resource "azurerm_linux_virtual_machine_scale_set" "app" {
  name                = "cs-vmss-app"
  location            = var.ubicacion
  resource_group_name = var.nombre_grupo_recursos
  sku                 = var.tamano_vm
  instances           = var.min_instancias
  zones               = var.zonas
  zone_balance        = true
  # Habilitamos el cifrado de los discos y datos
  # en el host fisico que ejecuta las maquinas virtuales.
  encryption_at_host_enabled = true

  # Evitamos que Azure cree maquinas adicionales durante el despliegue
  overprovision = false

  # Configuramos el usuario administrador sin utilizar contrasenas
  admin_username                  = var.usuario_admin
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.usuario_admin
    public_key = var.clave_ssh_publica
  }

  # Utilizamos Ubuntu como sistema operativo de las instancias
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # Configuramos el disco principal de las maquinas
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  # Conectamos las maquinas a nuestra subred y al balanceador
  # No asignamos direcciones IP publicas a las instancias
  network_interface {
    name    = "cs-nic-app"
    primary = true

    ip_configuration {
      name                                   = "ip-interna"
      primary                                = true
      subnet_id                              = var.subnet_app_id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.app.id]
    }
  }

  # Asignamos una identidad administrada para acceder a Key Vault
  # sin guardar credenciales dentro del codigo
  identity {
    type = "SystemAssigned"
  }

  # Permitimos que la aplicacion se configure al iniciar las maquinas
  # Sofia nos proporcionara el contenido de cloud-init
  custom_data = var.cloud_init

  # Utilizamos la sonda del balanceador para revisar el estado
  # de las instancias y realizar las actualizaciones gradualmente
  upgrade_mode    = "Rolling"
  health_probe_id = azurerm_lb_probe.app.id

  rolling_upgrade_policy {
    max_batch_instance_percent              = 50
    max_unhealthy_instance_percent          = 50
    max_unhealthy_upgraded_instance_percent = 50
    pause_time_between_batches              = "PT0S"
  }

  # Habilitamos la reparacion cuando una instancia presente fallas
  automatic_instance_repair {
    enabled      = true
    grace_period = "PT10M"
    action       = "Replace"
  }

  # Evitamos que Terraform cambie la cantidad de instancias
  # cuando el escalamiento automatico las aumente o disminuya
  lifecycle {
    ignore_changes = [instances]
  }

  # Esperamos que el balanceador tenga su regla configurada
  depends_on = [azurerm_lb_rule.http]
}



# Configuramos el escalamiento automatico de CaribeShop
# para ajustar la cantidad de maquinas segun la carga.

resource "azurerm_monitor_autoscale_setting" "app" {
  name                = "cs-autoscale-app"
  location            = var.ubicacion
  resource_group_name = var.nombre_grupo_recursos
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.app.id
  enabled             = true

  # Definimos el minimo y maximo de instancias permitidas
  profile {
    name = "perfil-principal"

    capacity {
      default = tostring(var.min_instancias)
      minimum = tostring(var.min_instancias)
      maximum = tostring(var.max_instancias)
    }

    # Aumentamos una instancia cuando el uso de CPU supera el 70 %
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.app.id
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    # Reducimos una instancia cuando el uso de CPU baja del 30 %
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.app.id
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
}
