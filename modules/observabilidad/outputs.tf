
output "log_analytics_id" {
  description = "ID del espacio de trabajo de Log Analytics"
  value       = azurerm_log_analytics_workspace.caribeshop.id
}

output "action_group_id" {
  description = "ID del grupo de acciones de Azure Monitor"
  value       = azurerm_monitor_action_group.caribeshop.id
}

output "health_alert_id" {
  description = "ID de la alerta del Load Balancer"
  value       = azurerm_monitor_metric_alert.health_probe.id
}
