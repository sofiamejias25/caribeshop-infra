
# E5 - Observabilidad de CaribeShop

# Espacio centralizado para registros y consultas.
resource "azurerm_log_analytics_workspace" "caribeshop" {
  name                = "log-caribeshop-dev"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku               = "PerGB2018"
  retention_in_days = 30
}

# Grupo de acciones para enviar alertas por correo.
resource "azurerm_monitor_action_group" "caribeshop" {
  name                = "cs-alertas"
  resource_group_name = var.resource_group_name
  short_name          = "CSAlertas"

  email_receiver {
    name                    = "equipo-caribeshop"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }
}

# Alerta cuando disminuye la disponibilidad
# observada por la sonda del Load Balancer.
resource "azurerm_monitor_metric_alert" "health_probe" {
  name                = "cs-alerta-health-probe"
  resource_group_name = var.resource_group_name
  scopes              = [var.lb_id]

  description = "Alerta cuando la disponibilidad promedio de la sonda es inferior al 100 %."
  severity    = 2
  enabled     = true
  frequency   = "PT1M"
  window_size = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Network/loadBalancers"
    metric_name      = "DipAvailability"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 100
  }

  action {
    action_group_id = azurerm_monitor_action_group.caribeshop.id
  }
}
