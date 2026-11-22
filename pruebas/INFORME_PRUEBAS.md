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
| URL evaluada | http://57.156.18.174 |
| Fecha de ejecución | 22 de noviembre de 2026 |
| Versión o commit evaluado | Pendiente de confirmar |
| Herramienta de pruebas | Locust 2.47.0 |
| Lenguaje de procesamiento | Python |
| Entorno | Aplicación desplegada en Microsoft Azure |

La aplicación fue desplegada en Azure y se utilizó la dirección IP pública del balanceador para realizar la prueba inicial. La ruta evaluada fue `GET /`.

## 4. Escenarios de prueba

Se definieron cinco escenarios para evaluar progresivamente el comportamiento de la aplicación.

| Escenario | Usuarios | Duración | Estado |
|---|---:|---:|---|
| Prueba de humo | 1 | 1 minuto | Ejecutada |
| Carga inicial | 5 | 2 minutos | Pendiente |
| Carga media | 10 | 3 minutos | Pendiente |
| Carga alta | 20 | 5 minutos | Pendiente |
| Prueba de estrés | 50 | 5 minutos | Pendiente |

**Nota:** Las pruebas de mayor concurrencia quedan pendientes de coordinación y autorización del equipo para evitar afectar la disponibilidad de la aplicación.

## 5. Métricas evaluadas

Se tienen en cuenta las siguientes métricas:

- **Solicitudes por segundo (RPS):** cantidad de solicitudes procesadas por segundo.
- **Tiempo promedio de respuesta:** tiempo promedio que tarda el servidor en responder.
- **Percentil 95 (P95):** tiempo de respuesta por debajo del cual se completó el 95 % de las solicitudes, según el cálculo de Locust.
- **Tasa de errores:** porcentaje de solicitudes que presentan fallos.
- **Total de solicitudes:** cantidad de peticiones realizadas durante la prueba.
- **Usuarios concurrentes:** cantidad de usuarios simulados al mismo tiempo.

## 6. Evidencias gráficas

Las evidencias generadas mediante el procesamiento de resultados se almacenan en `pruebas/resultados/`.

Archivos correspondientes a la prueba real de CaribeShop:

- `caribeshop_humo_rps.png`: comportamiento de las solicitudes por segundo.
- `caribeshop_humo_p95.png`: evolución del percentil 95 de los tiempos de respuesta.
- `caribeshop_humo_errores.png`: comportamiento de la tasa de errores.
- `caribeshop_humo_stats.csv`: estadísticas generales de la prueba.
- `caribeshop_humo_stats_history.csv`: historial de estadísticas durante la ejecución.

También se conservan los archivos de validación técnica realizados anteriormente contra httpbin.org. Estos no deben confundirse con los resultados de CaribeShop.

## 7. Resultados

### 7.1 Prueba de humo contra CaribeShop

Se ejecutó una prueba inicial contra la aplicación desplegada en Azure utilizando Locust, con un usuario simulado durante un minuto y realizando solicitudes a la ruta principal `GET /`.

**Resultados obtenidos:**

| Métrica | Resultado |
|---|---:|
| Usuarios simulados | 1 |
| Duración | 1 minuto |
| Total de solicitudes | 15 |
| Errores | 0 |
| Porcentaje de errores | 0 % |
| Tiempo promedio | 1544,81 ms |
| P95 | 16000 ms |
| RPS | 0,28 |
| URL evaluada | http://57.156.18.174 |

### 7.2 Análisis de resultados

La prueba de humo permitió comprobar que la aplicación recibió solicitudes sin registrar errores HTTP durante la ejecución.

Sin embargo, el tiempo promedio de respuesta fue de 1544,81 ms y el percentil 95 alcanzó los 16000 ms. Estos valores indican que algunas respuestas presentaron tiempos elevados y que es necesario investigar el comportamiento de la aplicación.

Aunque no se registraron errores, todavía no se puede concluir que el rendimiento sea satisfactorio. Se requiere revisar los tiempos de respuesta y realizar las pruebas adicionales para obtener una evaluación más completa.

## 8. Observaciones y limitaciones

Inicialmente se realizó una prueba de validación técnica contra `https://httpbin.org` para comprobar el funcionamiento de Locust, el procesamiento de archivos CSV y la generación de gráficas.

Posteriormente, la aplicación CaribeShop quedó desplegada en Azure y fue posible ejecutar la primera prueba real contra su dirección IP pública.

Las pruebas de carga inicial, carga media, carga alta y estrés permanecen pendientes de coordinación con el equipo.

**Importante:** los resultados obtenidos contra httpbin.org corresponden únicamente a una validación técnica. No representan el rendimiento ni la capacidad de la aplicación CaribeShop.

### 8.1 Resultados de validación técnica

| Métrica | Resultado |
|---|---:|
| Solicitudes | 133 |
| Errores | 0 |
| Tiempo promedio | 87,33 ms |
| P95 | 170 ms |
| RPS | 2,48 |
| Porcentaje de errores | 0 % |

Estos valores validan el funcionamiento de las herramientas, pero no corresponden al rendimiento de CaribeShop.
### 9. Análisis del tiempo de respuesta – Prueba de humo

Durante la prueba de humo, ejecutada con un usuario virtual durante un minuto, se registraron 15 solicitudes y ningún error HTTP.

Los resultados obtenidos fueron:

- Tiempo promedio: 1.544,81 ms.
- Tiempo mediano: 440 ms.
- Tiempo mínimo: 345,89 ms.
- Tiempo máximo: 15.667,79 ms.
- Percentil 95 (P95): 16.000 ms.
- Porcentaje de errores: 0 %.

Se identificó una demora puntual considerable, reflejada en el tiempo máximo y en el P95. Aunque no se presentaron errores ni excepciones, este comportamiento indica que es necesario investigar las causas de los tiempos elevados.

Debido a que la prueba se realizó con un solo usuario y únicamente 15 solicitudes, estos resultados son preliminares y no permiten determinar la capacidad máxima de la aplicación.

Los escenarios de carga inicial, media, alta y estrés quedan pendientes de coordinación y ejecución con el equipo.

## 10. Conclusiones

Se logró preparar y ejecutar la estructura inicial de pruebas de carga mediante Locust y herramientas de análisis en Python.

La prueba de humo contra la aplicación real desplegada en Azure registró 15 solicitudes sin errores HTTP. No obstante, los tiempos de respuesta promedio y P95 fueron elevados, por lo que se requiere investigar su comportamiento antes de establecer conclusiones definitivas sobre el rendimiento.

Se cuenta con scripts para ejecutar escenarios, registrar resultados y generar evidencias gráficas.

Quedan pendientes las pruebas de carga inicial, media, alta y estrés, cuya ejecución deberá coordinarse con el equipo de infraestructura.

Una vez completados los escenarios, se realizará un análisis comparativo de las métricas para identificar posibles problemas de rendimiento y oportunidades de mejora.