data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "caribeshop" {
  name                = var.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  rbac_authorization_enabled    = true
  purge_protection_enabled      = true
  soft_delete_retention_days    = 7
  public_network_access_enabled = true

  network_acls {
    default_action             = "Deny"
    bypass                     = "None"
    ip_rules                   = [var.operator_ip]
    virtual_network_subnet_ids = [var.subnet_app_id]
  }
}

# --- S5: Azure Policy con efecto Deny asignada al grupo de recursos ---
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_resource_group_policy_assignment" "deny_nic_public_ip" {
  name                 = "cs-deny-nic-public-ip"
  display_name         = "CaribeShop - Deny: interfaces de red sin IP publica"
  description          = "Impide crear o modificar NIC con IP publica en el grupo de CaribeShop (requisito S5)."
  resource_group_id    = data.azurerm_resource_group.rg.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/83a86a26-fd1f-447c-b59d-e51f44264114"
  enforce              = true
}