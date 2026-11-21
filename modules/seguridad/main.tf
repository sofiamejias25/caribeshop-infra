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