terraform {
  backend "azurerm" {
    resource_group_name  = "cs-tfstate-rg"
    storage_account_name = "cstfstate15943"
    container_name       = "tfstate"
    key                  = "caribeshop.tfstate"
    use_azuread_auth     = true
  }
}