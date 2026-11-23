# Informe de pruebas de carga - CaribeShop

## 1. Objetivo

Evaluar el comportamiento y rendimiento de la infraestructura y aplicación CaribeShop mediante pruebas de carga, con el propósito de identificar errores, medir los tiempos de respuesta y observar el comportamiento del sistema ante diferentes niveles de concurrencia y eventos de infraestructura en Microsoft Azure.

Se analizaron los resultados de las pruebas P1 y P2, incluyendo solicitudes procesadas, fallos, percentil 95 (P95), solicitudes por segundo (RPS) y comportamiento del escalamiento automático.

## 2. Herramientas utilizadas

- **Locust 2.47.0:** ejecución y simulación de usuarios concurrentes.
- **Python:** ejecución de scripts y procesamiento de resultados.
- **Pandas:** organización y análisis de datos.
- **Matplotlib:** generación de gráficas estadísticas.
- **Microsoft Azure:** infraestructura donde se desplegó la aplicación.
- **Git y GitHub:** control de versiones y almacenamiento de evidencias.

## 3. Entorno de pruebas

| Elemento | Descripción |
|---|---|
| Aplicación | CaribeShop |
| URL evaluada | http://57.156.18.174 |
| Fechas de ejecución | 22 y 23 de noviembre de 2026 |
| Versión de Locust | 2.47.0 |
| Lenguaje de procesamiento | Python |
| Infraestructura | Microsoft Azure |
| Herramienta de carga | Locust |

Las solicitudes se dirigieron a la aplicación desplegada en Azure mediante la dirección pública del balanceador de carga. La ruta principal evaluada fue `GET /`.

## 4. Escenarios de prueba

Se ejecutaron escenarios de carga y pruebas de comportamiento de la infraestructura, identificados como P1 y P2.

| Prueba | Descripción | Resultado |
|---|---|---|
| P1.1 | Carga con backlog 5 | Ejecutada |
| P1.1b | Carga con backlog 128 | Ejecutada |
| P1.2 | Carga sin carga de CPU adicional | Ejecutada |
| P1.2b | Carga con escalamiento | Ejecutada |
| P2.1 | Prueba de falla y reparación de instancia | Ejecutada |
| P2.2 | Prueba de caída de instancia en Azure | Ejecutada |

## 5. Métricas evaluadas

- **Solicitudes por segundo (RPS):** cantidad de solicitudes procesadas por segundo.
- **Tiempo promedio de respuesta:** tiempo promedio que tarda el servidor en responder.
- **Percentil 95 (P95):** tiempo de respuesta por debajo del cual se completó el 95 % de las solicitudes.
- **Tasa de errores:** porcentaje de solicitudes que presentaron fallos.
- **Total de solicitudes:** cantidad de peticiones realizadas durante cada prueba.
- **Usuarios concurrentes:** cantidad de usuarios simulados durante la ejecución.

## 6. Resultados generales de las pruebas P1 y P2

La siguiente tabla resume los resultados consolidados de las pruebas realizadas.

| Prueba | Peticiones | Fallos | P95 | RPS |
|---|---:|---:|---:|---:|
| P1.1 (backlog 5) | 38.951 | 2.265 (5,81 %) | 21 s | 57,7 |
| P1.1b (backlog 128) | 51.437 | 666 (1,29 %) | 7,7 s | 76,1 |
| P1.2 (sin carga de CPU) | 86.584 | 313 (0,36 %) | 3,5 s | 46,6 |
| P1.2b (con escalado) | 53.112 | 172 (0,32 %) | 7,5 s | 28,6 |
| P2.2 | 5.965 | 9 (0,15 %) | 3,4 s | 5,0 |

### 6.1 Análisis de resultados P1

En P1.1 se registraron 38.951 peticiones y 2.265 fallos, equivalentes al 5,81 %. El P95 fue de 21 segundos, lo que evidencia tiempos de respuesta elevados bajo ese escenario.

En P1.1b se procesaron 51.437 peticiones y se registraron 666 fallos (1,29 %). El P95 disminuyó a 7,7 segundos y el rendimiento alcanzó 76,1 RPS.

En P1.2 se registraron 86.584 peticiones, con 313 fallos (0,36 %), un P95 de 3,5 segundos y 46,6 RPS.

En P1.2b, escenario con escalamiento, se procesaron 53.112 peticiones y se registraron 172 fallos (0,32 %). El P95 fue de 7,5 segundos y el rendimiento de 28,6 RPS.

Los resultados muestran diferencias en el comportamiento de la aplicación entre escenarios. La comparación debe considerar las condiciones particulares de cada prueba y no únicamente el número de solicitudes por segundo.

### 6.2 Análisis de resultados P2.1

La prueba P2.1 registró los siguientes resultados:

| Métrica | Resultado |
|---|---:|
| Total de solicitudes | 2.112 |
| Solicitudes exitosas | 1.836 |
| Solicitudes fallidas | 276 |
| Porcentaje de fallos | 13,07 % |
| Porcentaje de éxito | 86,93 % |

Los archivos de Locust muestran errores de conexión (`ConnectTimeoutError`) hacia la dirección `57.156.18.174`, utilizando el puerto 80.

El análisis de los eventos registrados en Azure permite establecer la siguiente secuencia temporal (UTC):

| Evento | Hora UTC |
|---|---|
| Creación de la bandera de falla lógica | 16:30:07 |
| Instancia retirada del tráfico | 16:30:16 |
| Azure inicia la reparación (`repairVM`) | 16:41:11 |
| Creación de la nueva instancia | 16:41:12 |
| Nueva instancia responde en el balanceador | 16:41:56 |
| Finalización de la reparación | 16:46:14 |

Los fallos de conexión comenzaron antes de la creación de la bandera de falla lógica y continuaron durante el intervalo de recuperación. Por esta razón, no es correcto atribuir los 276 fallos exclusivamente a la falla lógica.

La prueba permite observar el impacto de los problemas de disponibilidad y el proceso de reparación automática de la infraestructura. Los archivos crudos de Locust permiten consultar los errores y sus marcas temporales.

### 6.3 Análisis de resultados P2.2

P2.2 registró 5.965 solicitudes, de las cuales 9 presentaron fallos, equivalentes al 0,15 %. El P95 fue de 3,4 segundos y el rendimiento alcanzó 5,0 RPS.

En las gráficas se incorporó la marca temporal del evento de caída registrado en Azure a las 18:13:09 UTC del 22 de noviembre de 2026. Esto permite comparar el comportamiento de las métricas de carga con el evento de infraestructura.

## 7. Análisis temporal del escalamiento y la disponibilidad

Para analizar la relación entre la carga y el comportamiento de Azure se generaron gráficas de solicitudes por segundo, P95 y porcentaje de errores.

### 7.1 P1.2b: escalamiento automático

Se utilizaron los registros de Locust y los eventos de instancias de Azure para identificar los cambios de capacidad.

Los eventos marcados en las gráficas fueron:

- **Scale-out:** 05:52:06 UTC del 23 de noviembre de 2026.
- **Scale-in:** 06:03:35 UTC del 23 de noviembre de 2026.

Las gráficas permiten observar la evolución de las solicitudes, los tiempos de respuesta y los errores durante el intervalo en que aumentó y disminuyó el número de instancias.

### 7.2 P2.2: evento de caída

En las gráficas de P2.2 se marcó el evento de caída de Azure a las 18:13:09 UTC del 22 de noviembre de 2026.

La comparación temporal permite examinar el comportamiento de las métricas de Locust alrededor del evento registrado en la infraestructura.

## 8. Evidencias

Las evidencias se encuentran organizadas en los directorios `pruebas/` y `evidencias/`.

### 8.1 Datos crudos de P2.1

Se conservaron los siguientes archivos originales de Locust:

- `evidencias/P2_1.html`
- `evidencias/P2_1_stats.csv`
- `evidencias/P2_1_stats_history.csv`
- `evidencias/P2_1_failures.csv`
- `evidencias/P2_1_exceptions.csv`

Estos archivos permiten consultar las estadísticas generales, el historial de solicitudes y los errores registrados durante la prueba.

### 8.2 Gráficas P1.2b

- `evidencias/P1_2b_rps_azure.png`
- `evidencias/P1_2b_p95_azure.png`
- `evidencias/P1_2b_errores_azure.png`

Scripts utilizados:

- `pruebas/graficos_p1_2b.py`

### 8.3 Gráficas P2.2

- `evidencias/P2_2_rps_azure.png`
- `evidencias/P2_2_p95_azure.png`
- `evidencias/P2_2_errores_azure.png`

Script utilizado:

- `pruebas/graficos_p2_2.py`

Las gráficas incluyen las marcas temporales de los eventos de infraestructura correspondientes a cada escenario.

## 9. Validación técnica de herramientas

Inicialmente se realizó una prueba de validación técnica contra `https://httpbin.org` para comprobar el funcionamiento de Locust, el procesamiento de archivos CSV y la generación de gráficas.

Los resultados de esa validación fueron:

| Métrica | Resultado |
|---|---:|
| Solicitudes | 133 |
| Errores | 0 |
| Tiempo promedio | 87,33 ms |
| P95 | 170 ms |
| RPS | 2,48 |
| Porcentaje de errores | 0 % |

Estos valores corresponden exclusivamente a la validación técnica contra httpbin.org. No representan el rendimiento de CaribeShop y no deben mezclarse con los resultados de las pruebas ejecutadas contra Azure.

La prueba de humo inicial contra CaribeShop también se conserva como una medición preliminar independiente. En ella se registraron 15 solicitudes, sin errores, con un tiempo promedio de 1.544,81 ms y un P95 de 16.000 ms.

## 10. Observaciones y limitaciones

- Los resultados dependen de las condiciones de infraestructura y carga presentes durante cada ejecución.
- Los eventos de Azure se analizaron utilizando sus marcas temporales en UTC.
- Los fallos de P2.1 comenzaron antes de la creación de la bandera de falla lógica; por tanto, no deben atribuirse todos a un único evento.
- Las gráficas temporales documentadas en este informe corresponden a P1.2b y P2.2.
- Los archivos CSV y HTML de Locust se conservan como evidencia para permitir la revisión de los resultados.
- La validación contra httpbin.org es independiente de las pruebas realizadas sobre CaribeShop.

## 11. Conclusiones

Se ejecutaron pruebas de carga y disponibilidad sobre CaribeShop desplegada en Microsoft Azure, utilizando Locust para generar solicitudes y Python para procesar los resultados.

Los escenarios P1 permitieron comparar el comportamiento de la aplicación bajo diferentes condiciones de carga. Se observaron porcentajes de fallos entre 0,32 % y 5,81 %, y valores de P95 entre 3,5 y 21 segundos.

En P2.1 se registraron 276 fallos de conexión de un total de 2.112 solicitudes. El análisis temporal mostró que los fallos comenzaron antes de la activación de la falla lógica y que Azure inició posteriormente un proceso de reparación automática.

En P2.2 se registró un porcentaje de fallos del 0,15 %. La gráfica temporal permite relacionar las métricas de Locust con el evento de caída de Azure.

Finalmente, se conservaron los datos crudos y las gráficas correspondientes a los escenarios documentados. Estas evidencias permiten respaldar el análisis del rendimiento, la disponibilidad y el comportamiento de la infraestructura durante las pruebas.
