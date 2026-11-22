output "key_vault_id" {
  description = "ID del Key Vault para la asignación de roles."
  value       = azurerm_key_vault.caribeshop.id
}

output "key_vault_uri" {
  description = "URI que usará la aplicación para conectarse al Key Vault."
  value       = azurerm_key_vault.caribeshop.vault_uri
}

output "policy_assignment_id" {
  description = "ID de la asignación de la política Deny (S5)."
  value       = azurerm_resource_group_policy_assignment.deny_nic_public_ip.id
}