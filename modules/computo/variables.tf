
# Variables del modulo de computo de CaribeShop
# Aqui definimos los datos que necesitamos para configurar
# las maquinas virtuales, el balanceador y el escalamiento.

# Definimos la region donde desplegamos los recursos
variable "ubicacion" {
  description = "Region donde desplegamos los recursos"
  type        = string
  default     = "chilecentral"
}

# Recibimos el nombre del grupo de recursos del proyecto
variable "nombre_grupo_recursos" {
  description = "Nombre del grupo de recursos de CaribeShop"
  type        = string
}

# Recibimos la subred que configuramos en el modulo de red
variable "subnet_app_id" {
  description = "Identificador de la subred de la aplicacion"
  type        = string
}

# Definimos las zonas donde distribuimos las instancias
variable "zonas" {
  description = "Zonas de disponibilidad para las maquinas virtuales"
  type        = list(string)
  default     = ["1", "2", "3"]
}

# Definimos el modelo de maquina que acordamos para el proyecto
variable "tamano_vm" {
  description = "Modelo de maquina virtual que utilizamos"
  type        = string
  default     = "Standard_B2ats_v2"
}

# Establecemos la cantidad minima de instancias
variable "min_instancias" {
  description = "Cantidad minima de instancias del VMSS"
  type        = number
  default     = 2
}

# Establecemos la cantidad maxima de instancias
variable "max_instancias" {
  description = "Cantidad maxima de instancias del VMSS"
  type        = number
  default     = 3
}

# Recibimos el usuario administrador de las maquinas
variable "usuario_admin" {
  description = "Usuario administrador de las instancias"
  type        = string
  default     = "csadmin"
}

# Recibimos la clave publica SSH sin guardar claves privadas
variable "clave_ssh_publica" {
  description = "Clave publica SSH para configurar las instancias"
  type        = string
}

# Recibimos la configuracion de inicio de la aplicacion
# para que las maquinas se preparen automaticamente
variable "cloud_init" {
  description = "Configuracion cloud-init codificada en base64"
  type        = string
}
