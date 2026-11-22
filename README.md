
# CaribeShop — Infraestructura en Azure

Proyecto integrador de Infraestructura para TI.

Implementación de infraestructura modular en Microsoft Azure utilizando Terraform, con automatización DevSecOps mediante GitHub Actions y Checkov, observabilidad mediante Azure Monitor y pruebas de carga y disponibilidad con Locust.

## 1. Objetivo

Diseñar, implementar y evaluar una infraestructura en Azure que incorpore alta disponibilidad, escalamiento automático, gestión segura de secretos, monitoreo y validaciones automatizadas de seguridad.

## 2. Arquitectura

La solución contempla los siguientes componentes:

- **Azure Virtual Network:** red virtual y subred de aplicación.
- **Network Security Group:** control del tráfico permitido.
- **Azure Load Balancer Standard:** distribución de solicitudes y sonda HTTP `/health`.
- **Virtual Machine Scale Set:** instancias Linux con escalamiento automático.
- **Managed Identity:** identidad administrada para acceder a servicios Azure.
- **Azure Key Vault:** almacenamiento protegido de secretos y acceso mediante RBAC.
- **Azure Policy:** política Deny para restringir configuraciones no permitidas.
- **Log Analytics:** centralización de registros.
- **Azure Monitor:** alerta de disponibilidad y notificaciones por correo.
- **Azure Storage:** almacenamiento remoto del estado de Terraform.
- **GitHub Actions y Checkov:** integración continua y análisis estático de seguridad.

La aplicación Python proporciona los endpoints `/`, `/health` y `/secreto`.

## 3. Organización del repositorio

```text
caribeshop-infra/
├── .github/workflows/
│   └── terraform.yml
├── app/
│   ├── app.py
│   └── cloud-init.yaml
├── bootstrap/
│   └── crear-backend.sh
├── modules/
│   ├── red/
│   ├── computo/
│   ├── seguridad/
│   └── observabilidad/
├── pruebas/
├── evidencias/
├── backend.tf
├── providers.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
└── README.md
```

## 4. Responsabilidades

| Integrante | Responsabilidad |
|---|---|
| Bianca | Red, cómputo, balanceador, VMSS y autoscaling |
| Sofía | Aplicación, Key Vault, identidad y Azure Policy |
| Sara | Terraform raíz, DevSecOps y observabilidad |
| Ana | Locust, pruebas, métricas, evidencias e informe |

## 5. Requisitos previos

- Terraform >= 1.6
- Azure CLI
- Git
- Cuenta de GitHub con acceso al repositorio
- Acceso autorizado a la suscripción de Azure

El entorno local fue validado con Terraform 1.16.4 y AzureRM 4.81.0.

## 6. Configuración de Terraform

El backend remoto utiliza Azure Storage:

- Grupo de recursos: `cs-tfstate-rg`
- Storage Account: `cstfstate15943`
- Contenedor: `tfstate`
- Clave: `caribeshop.tfstate`
- Autenticación: Microsoft Entra ID

El Storage del estado es independiente del grupo de recursos de la aplicación.

Antes de ejecutar el script `bootstrap/crear-backend.sh`, se debe verificar si el backend ya existe. El script genera un nombre de Storage y no debe ejecutarse nuevamente sin coordinación.

### Validación local sin acceso al backend

```bash
terraform init -backend=false
terraform fmt -check -recursive
terraform validate
```

Este procedimiento permite validar la configuración sin conectarse al estado remoto.

### Despliegue del entorno compartido

La responsable autorizada del despliegue debe configurar las variables requeridas y comprobar el acceso al backend antes de ejecutar:

```bash
terraform init
terraform plan
terraform apply
```

Para destruir recursos administrados por Terraform:

```bash
terraform destroy
```

Los comandos de despliegue y destrucción son exclusivos de la persona autorizada por el equipo. No se deben ejecutar simultáneamente desde diferentes equipos.

El backend remoto debe conservarse mientras sea necesario mantener el estado del proyecto.

## 7. Variables principales

| Variable | Descripción |
|---|---|
| `subscription_id` | Suscripción Azure |
| `location` | Región de despliegue |
| `prefix` | Prefijo de recursos |
| `clave_ssh_publica` | Clave pública SSH |
| `key_vault_name` | Nombre único del Key Vault |
| `operator_ip` | Dirección IP autorizada para Key Vault |
| `alert_email` | Correo receptor de las alertas de Azure Monitor |

Los valores del despliegue se proporcionan mediante mecanismos autorizados. Los archivos `.tfvars` reales no se publican en GitHub.

## 8. Pipeline DevSecOps

El workflow se encuentra en:

`.github/workflows/terraform.yml`

Se ejecuta en Pull Requests dirigidos a `main`, en cambios publicados en `main` y mediante ejecución manual.

Etapas:

1. Descargar el repositorio.
2. Instalar Terraform.
3. Verificar formato con `terraform fmt -check -recursive`.
4. Inicializar sin backend mediante `terraform init -backend=false`.
5. Validar la configuración con `terraform validate`.
6. Analizar seguridad con Checkov.

Checkov está configurado con `soft_fail: false`, por lo que los hallazgos no exceptuados pueden hacer fallar el workflow.

Para impedir efectivamente un merge cuando falle un check, el repositorio debe tener configurada una regla de protección de la rama `main` que lo exija.

Los cambios deben realizarse en ramas independientes y proponerse mediante Pull Requests.

## 9. Observabilidad

El módulo `modules/observabilidad/` define:

### Log Analytics

Workspace `cs-log-analytics`, con retención configurada de 30 días.

### Azure Monitor

Grupo de acciones `cs-alertas`, con receptor por correo configurable.

Alerta `cs-alerta-health-probe`:

- Recurso supervisado: Azure Load Balancer.
- Métrica: `DipAvailability`.
- Agregación: Average.
- Umbral: inferior al 100 %.
- Frecuencia: 1 minuto.
- Ventana: 5 minutos.
- Severidad: 2.

### Auditoría de Key Vault

El recurso `azurerm_monitor_diagnostic_setting.key_vault`, definido en la raíz, configura el envío de eventos `AuditEvent` hacia Log Analytics.

La creación efectiva de estos recursos, la llegada de registros y la recepción de alertas deben verificarse en Azure después del despliegue.

## 10. Pruebas

Las pruebas del proyecto se organizan en:

- **P1 — Rendimiento y escalabilidad:** capacidad, carga escalonada, scale-out y scale-in.
- **P2 — Resiliencia:** falla lógica y eliminación abrupta de una instancia.
- **P3 — Seguridad:** acceso a secretos desde una red no autorizada, tráfico de salida y aplicación de Azure Policy Deny.

Locust genera estadísticas de solicitudes, tiempos de respuesta, errores y resultados exportables.

Los resultados y capturas se almacenan en `pruebas/resultados/` y `evidencias/`, según corresponda.

## 11. Riesgos y excepciones de seguridad

| Control | Situación | Tratamiento |
|---|---|---|
| CKV_AZURE_160 | HTTP público en puerto 80 | Excepción existente para el entorno académico |
| CKV2_AZURE_32 | Key Vault sin Private Endpoint | Hallazgo pendiente de decisión y resolución |

### Riesgo aceptado: HTTP público

La aplicación utiliza HTTP para cumplir con la arquitectura y las pruebas del taller.

Impacto: el tráfico HTTP no proporciona confidencialidad mediante TLS.

Medidas actuales: NSG, balanceador de carga y control del alcance del entorno.

Mitigación futura: implementar HTTPS con TLS, restringir el acceso y eliminar la excepción antes de un despliegue productivo.

### Riesgo pendiente: Key Vault sin Private Endpoint

La configuración utiliza reglas de firewall, acceso restringido por IP y subred, RBAC e identidad administrada.

Estas medidas no equivalen a un Private Endpoint.

La decisión de implementar conectividad privada o documentar una excepción justificada debe coordinarse con la responsable del módulo de seguridad.

No se considera un riesgo aceptado hasta que dicha decisión sea aprobada y documentada.

## 12. Evidencias y estado de validación

Las validaciones locales de Terraform se ejecutaron correctamente.

El pipeline de GitHub Actions logró completar las etapas de formato, inicialización y validación. Checkov detectó el control `CKV2_AZURE_32`, por lo que el análisis de seguridad permanece pendiente de resolución.

El módulo de observabilidad está implementado en código y pasó `terraform validate`. Su despliegue y las pruebas de recepción de registros y alertas siguen pendientes de verificación.

Las capturas de los controles y pruebas deben conservarse en la carpeta `evidencias/`.

## 13. Consideraciones de seguridad

- No publicar archivos `*.tfstate` ni `*.tfvars` reales.
- No almacenar claves privadas ni secretos en Git.
- Utilizar identidad administrada y permisos mínimos.
- Mantener Checkov bloqueante para hallazgos no exceptuados.
- Justificar toda excepción de seguridad.
- Evitar despliegues simultáneos contra el mismo estado.
- Destruir los recursos de prueba cuando finalicen las actividades autorizadas.
