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
  }))
}
