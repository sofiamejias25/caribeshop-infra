
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

## 4. Responsabilidades

| Integrante | Responsabilidad |
|---|---|
| Bianca | Red, cómputo, balanceador, VMSS y autoscaling |
| Sofía | Aplicación, Key Vault, identidad y Azure Policy |
| Sara | Terraform raíz, DevSecOps y observabilidad |
| Ana | Locust, pruebas, métricas, evidencias e informe |

## 5. Requisitos previos

- Terraform >= 1.6.
- Azure CLI.
- Git.
- Cuenta de GitHub con acceso al repositorio.
- Acceso autorizado a la suscripción de Azure.

El entorno local fue validado con Terraform 1.16.4 y AzureRM 4.81.0.

## 6. Configuración de Terraform

El backend remoto utiliza Azure Storage:

- Grupo de recursos: `cs-tfstate-rg`.
- Storage Account: `cstfstate15943`.
- Contenedor: `tfstate`.
- Clave: `caribeshop.tfstate`.
- Autenticación: Microsoft Entra ID.
- Región: `chilecentral`.

El Storage del estado es independiente del grupo de recursos de la aplicación.

Se verificó mediante Azure CLI que la cuenta de almacenamiento existe, presenta estado `Succeeded` y tiene deshabilitado el acceso mediante claves compartidas (`allowSharedKeyAccess = false`).

La cuenta de Sara dispone de permisos de lectura sobre los recursos de la suscripción, pero no de acceso al contenido de los blobs del estado remoto. Esta separación responde al principio de mínimo privilegio.

Antes de ejecutar `bootstrap/crear-backend.sh`, se debe comprobar si el backend ya existe. El script genera un nombre de Storage y no debe ejecutarse nuevamente sin coordinación.

### Validación local sin acceso al backend

    terraform init -backend=false
    terraform fmt -check -recursive
    terraform validate

Este procedimiento permite validar la configuración sin conectarse al estado remoto.

### Despliegue del entorno compartido

La persona autorizada debe configurar las variables requeridas y comprobar el acceso al backend antes de ejecutar:

    terraform init
    terraform plan
    terraform apply

Para destruir los recursos administrados por Terraform:

    terraform destroy

Los comandos de despliegue y destrucción deben ejecutarse únicamente por la persona autorizada por el equipo, evitando operaciones simultáneas sobre el estado remoto.

El backend debe conservarse mientras sea necesario mantener el estado del proyecto.

## 7. Variables principales

| Variable | Descripción |
|---|---|
| `subscription_id` | Identificador de la suscripción de Azure |
| `location` | Región de despliegue |
| `prefix` | Prefijo de los recursos |
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
3. Verificar formato mediante `terraform fmt -check -recursive`.
4. Inicializar sin backend mediante `terraform init -backend=false`.
5. Validar la configuración mediante `terraform validate`.
6. Analizar seguridad con Checkov.

Checkov utiliza `soft_fail: false`, por lo que los hallazgos no exceptuados provocan el fallo del análisis.

Para impedir efectivamente un merge cuando falle un check, el repositorio debe tener una regla de protección de `main` que exija esa validación.

### Evidencia D2: detección y corrección de seguridad

El PR #9, creado desde `feature/devsecops`, permitió comprobar el funcionamiento del pipeline bloqueante.

El análisis reportó:

- 24 controles aprobados.
- 1 control fallido.
- 1 control omitido mediante excepción documentada.

El hallazgo fallido fue `CKV2_AZURE_32`, correspondiente a la ausencia de Private Endpoint en Azure Key Vault.

El PR #9 se conserva como evidencia de la detección y se cerrará sin fusionar.

La corrección se prepara en la rama `sara/fix-checkov`, creada a partir de `feature/devsecops`. Esta rama incorpora el trabajo anterior y una excepción justificada, junto con ajustes de integración de observabilidad.

El nuevo Pull Request deberá pasar las validaciones de GitHub Actions antes de su revisión e integración.

## 9. Observabilidad

El módulo `modules/observabilidad/` define los recursos de monitoreo de CaribeShop.

### Log Analytics

Se utiliza el workspace existente `log-caribeshop-dev`, ubicado en `chilecentral`.

Su configuración Terraform establece:

- SKU: `PerGB2018`.
- Retención: 30 días.

El recurso será incorporado al estado de Terraform mediante un bloque `import`, evitando crear otro workspace.

### Azure Monitor

El grupo de acciones `cs-alertas` permite enviar notificaciones al correo configurado mediante la variable `alert_email`.

La alerta `cs-alerta-health-probe` utiliza:

- Recurso supervisado: Azure Load Balancer.
- Métrica: `DipAvailability`.
- Agregación: `Average`.
- Umbral: inferior al 100 %.
- Frecuencia: 1 minuto.
- Ventana: 5 minutos.
- Severidad: 2.

### Auditoría de Key Vault

El recurso `azurerm_monitor_diagnostic_setting.key_vault`, definido en el `main.tf` de la raíz, utiliza el nombre `caribeshop-keyvault-audit`.

Su configuración envía eventos de la categoría `AuditEvent` hacia Log Analytics.

Este diagnóstico ya existe en Azure, por lo que se declara un bloque `import` para incorporarlo al estado de Terraform sin duplicarlo.

### Adopción de recursos existentes

El `main.tf` de la raíz contiene dos bloques `import` para:

1. `module.observabilidad.azurerm_log_analytics_workspace.caribeshop`.
2. `azurerm_monitor_diagnostic_setting.key_vault`.

La configuración y las importaciones deberán revisarse mediante `terraform plan` antes de ejecutar `apply`, para evitar reemplazos o modificaciones inesperadas.

La recepción de registros y la activación de alertas se verificarán posteriormente en Azure.

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
| `CKV_AZURE_160` | HTTP público en el puerto 80 | Excepción documentada para el entorno académico |
| `CKV2_AZURE_32` | Key Vault sin Private Endpoint | Excepción justificada y autorizada para el entorno académico |

### Riesgo aceptado: HTTP público

La aplicación utiliza HTTP para cumplir con la arquitectura y las pruebas del taller.

**Impacto:** el tráfico HTTP no proporciona confidencialidad mediante TLS.

**Medidas actuales:** NSG, balanceador de carga y control del alcance del entorno.

**Mitigación futura:** implementar HTTPS con TLS, restringir el acceso y eliminar la excepción antes de un despliegue productivo.

### Riesgo aceptado: Key Vault sin Private Endpoint

**Hallazgo:** `CKV2_AZURE_32`.

**Descripción:** El Key Vault de CaribeShop no utiliza Private Endpoint y mantiene habilitado su endpoint público.

**Impacto:** un atacante con credenciales válidas podría intentar acceder al servicio desde Internet. El firewall restringe las solicitudes, pero no proporciona el mismo aislamiento de red que Private Link.

**Medidas de mitigación:**

- Firewall con `default_action = "Deny"`.
- Acceso de red limitado a `snet-app` mediante service endpoint y a la IP autorizada de la operadora.
- Configuración `bypass = "None"`.
- Identidad administrada del VMSS con el rol `Key Vault Secrets User`.
- Protección contra eliminación permanente mediante purge protection.
- Auditoría de eventos `AuditEvent` hacia Log Analytics.

**Evidencia de seguridad:** en la prueba P3.1, un usuario con el rol `Key Vault Secrets Officer` intentó consultar el secreto desde Azure Cloud Shell. La solicitud fue rechazada con `ForbiddenByFirewall`, demostrando la aplicación de las restricciones de red.

**Mejora recomendada para producción:**

- Implementar Azure Private Endpoint.
- Configurar la zona DNS privada `privatelink.vaultcore.azure.net`.
- Establecer `public_network_access_enabled = false`.
- Verificar la conectividad privada desde las instancias autorizadas.

**Tratamiento:** excepción documentada y autorizada para el entorno académico de CaribeShop. No se considera una solución equivalente a implementar Private Endpoint.

## 12. Evidencias y estado de validación

Las validaciones locales de Terraform se ejecutaron correctamente.

### S1 — Backend remoto

Se verificó mediante Azure CLI la configuración de la cuenta de almacenamiento:

- Nombre: `cstfstate15943`.
- Región: `chilecentral`.
- Estado: `Succeeded`.
- Claves compartidas deshabilitadas.

Evidencia: `evidencias/S1_backend_storage.jpeg`.

### D1 y D2 — DevSecOps

El pipeline de GitHub Actions completó correctamente las etapas de formato, inicialización y validación.

Checkov detectó el hallazgo `CKV2_AZURE_32` y provocó el fallo del análisis.

Evidencia: `evidencias/D2_checkov_pr_fallido.jpeg`.

La nueva rama `sara/fix-checkov` incorpora el tratamiento documentado del hallazgo.

La ejecución verde del nuevo PR queda pendiente de comprobación.

### E5 — Observabilidad

El módulo de observabilidad está implementado en código y pasó `terraform validate`.

Se actualizaron los nombres de los recursos existentes para permitir su adopción mediante Terraform.

El despliegue, la importación efectiva de los recursos y las pruebas de recepción de registros y alertas todavía requieren verificación.

## 13. Consideraciones de seguridad

- No publicar archivos `*.tfstate` ni `.tfvars` reales.
- No almacenar claves privadas ni secretos en Git.
- Utilizar identidad administrada y permisos mínimos.
- Mantener Checkov bloqueante para hallazgos no exceptuados.
- Documentar y justificar toda excepción de seguridad.
- Evitar despliegues simultáneos contra el mismo estado.
- Revisar `terraform plan` antes de aplicar cambios.
- Destruir los recursos de prueba cuando finalicen las actividades autorizadas.
