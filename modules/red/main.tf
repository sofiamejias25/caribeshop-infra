
# Red de CaribeShop
# Aqui configuramos la red donde van a estar las maquinas virtuales
# y las reglas de seguridad para controlar las conexiones.

# Creamos la red virtual principal de CaribeShop
resource "azurerm_virtual_network" "principal" {
  name                = "cs-vnet"
  location            = var.ubicacion
  resource_group_name = var.nombre_grupo_recursos
  address_space       = ["10.20.0.0/16"]
}

# Creamos la subred donde estaran las instancias de la aplicacion
resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = var.nombre_grupo_recursos
  virtual_network_name = azurerm_virtual_network.principal.name
  address_prefixes     = ["10.20.1.0/24"]

  # Habilitamos la conexion con Key Vault para la parte de seguridad
  service_endpoints = ["Microsoft.KeyVault"]
}

# Creamos el grupo de seguridad para controlar el trafico de la subred
resource "azurerm_network_security_group" "app" {
  name                = "cs-nsg-app"
  location            = var.ubicacion
  resource_group_name = var.nombre_grupo_recursos
}


# Permitimos las conexiones HTTP desde Internet por el puerto 80
# Este acceso es necesario para que los usuarios puedan entrar a CaribeShop
resource "azurerm_network_security_rule" "http" {
  #checkov:skip=CKV_AZURE_160:Permitimos HTTP publico porque el taller requiere acceso a la tienda mediante el balanceador. Documentamos este riesgo para el entorno de pruebas.
  name                        = "permitir-http"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = var.nombre_grupo_recursos
  network_security_group_name = azurerm_network_security_group.app.name
}


# Permitimos que el balanceador revise si las instancias estan funcionando
resource "azurerm_network_security_rule" "sonda" {
  name                        = "permitir-sonda-lb"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = var.nombre_grupo_recursos
  network_security_group_name = azurerm_network_security_group.app.name
}

# Asociamos el grupo de seguridad con la subred de la aplicacion
resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}
