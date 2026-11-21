
# Informe de pruebas de carga - CaribeShop

## 1. Objetivo

Evaluar el comportamiento y rendimiento de la infraestructura y aplicación CaribeShop mediante pruebas de carga, con el propósito de identificar posibles errores, medir los tiempos de respuesta y observar el comportamiento del sistema ante diferentes niveles de concurrencia.

## 2. Herramientas utilizadas

- **Locust:** ejecución y simulación de usuarios concurrentes.
- **Python:** ejecución de scripts y procesamiento de resultados.
- **Pandas:** organización y análisis de datos.
- **Matplotlib:** generación de gráficas estadísticas.
- **Git y GitHub:** control de versiones y almacenamiento de evidencias.

## 3. Entorno de pruebas

| Elemento | Descripción |
|---|---|
| Aplicación | CaribeShop |
| URL evaluada | Pendiente de disponibilidad |
| Fecha de ejecución | Pendiente |
| Versión o commit evaluado | Pendiente |
| Herramienta de pruebas | Locust |
| Lenguaje de procesamiento | Python |
| Entorno | Pendiente de confirmar |

## 4. Escenarios de prueba

Se proponen los siguientes escenarios para evaluar progresivamente el comportamiento de la aplicación.

| Escenario | Usuarios | Duración | Estado |
|---|---:|---:|---|
| Prueba de humo | 1 | 1 minuto | Pendiente |
| Carga inicial | 5 | 2 minutos | Pendiente |
| Carga media | 10 | 3 minutos | Pendiente |
| Carga alta | 20 | 5 minutos | Pendiente |
| Prueba de estrés | 50 | 5 minutos | Pendiente |

**Nota:** Los escenarios representan una planificación inicial. Su ejecución dependerá de la disponibilidad de la aplicación y de la autorización para realizar las pruebas.

## 5. Métricas evaluadas

Se tendrán en cuenta las siguientes métricas:

- **Solicitudes por segundo (RPS):** cantidad de solicitudes procesadas por segundo.
- **Tiempo promedio de respuesta:** tiempo promedio que tarda el servidor en responder.
- **Percentil 95 (p95):** tiempo dentro del cual se completa el 95 % de las solicitudes.
- **Tasa de errores:** porcentaje de solicitudes que presentan fallos.
- **Total de solicitudes:** cantidad de peticiones realizadas durante la prueba.
- **Usuarios concurrentes:** cantidad de usuarios simulados al mismo tiempo.

## 6. Evidencias gráficas

Las evidencias generadas mediante el procesamiento de resultados se almacenan en `pruebas/resultados/`.

Archivos disponibles:

- `rps.png`: comportamiento de las solicitudes por segundo.
- `p95.png`: evolución del percentil 95 de los tiempos de respuesta.
- `errores.png`: comportamiento de la tasa de errores.
- `locust_stats.csv`: estadísticas generales de las pruebas.
- `locust_stats_history.csv`: historial de estadísticas durante la ejecución.
- `locust_failures.csv`: registro de solicitudes fallidas.
- `locust_exceptions.csv`: registro de excepciones.

## 7. Resultados

La ejecución de las pruebas contra la aplicación CaribeShop está pendiente.

Se registrarán los resultados de cada escenario, incluyendo:

- Número total de solicitudes.
- Tiempo promedio de respuesta.
- Percentil 95.
- Solicitudes exitosas y fallidas.
- Solicitudes por segundo.
- Comportamiento general del sistema.

Los resultados se documentarán una vez se disponga de la URL y del entorno de pruebas de CaribeShop.

## 8. Observaciones y limitaciones

Se realizó una prueba inicial contra `https://httpbin.org` con el propósito de verificar el funcionamiento de Locust y el procesamiento de los archivos CSV.

Esta prueba permitió validar la configuración de la herramienta y la generación de gráficas.

**Importante:** los resultados obtenidos contra httpbin.org corresponden únicamente a una prueba de validación técnica. No representan el rendimiento ni la capacidad de la aplicación CaribeShop.

La evaluación definitiva depende de disponer de una instancia funcional de la aplicación.
### 8.1 Resultados de validación técnica

Se ejecutó una prueba de demostración contra httpbin.org.

| Métrica | Resultado |
|---|---:|
| Solicitudes | 133 |
| Errores | 0 |
| Tiempo promedio | 87.33 ms |
| P95 | 170 ms |
| RPS | 2.48 |
| Porcentaje de errores | 0 % |

Estos valores validan el funcionamiento de las herramientas, pero no corresponden al rendimiento de CaribeShop.

## 9. Conclusiones

La estructura de pruebas de carga se encuentra preparada mediante Locust y herramientas de análisis en Python.

Se cuenta con scripts para ejecutar pruebas y generar evidencias gráficas de rendimiento.

Sin embargo, todavía no es posible establecer conclusiones sobre el rendimiento de CaribeShop, debido a que falta ejecutar los escenarios contra la aplicación real.

Una vez disponible el entorno, se analizarán las métricas obtenidas para identificar posibles problemas de rendimiento y oportunidades de mejora.
