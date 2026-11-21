
# Guía de ejecución de pruebas de carga - CaribeShop

## Requisito previo

Tener disponible la URL de la aplicación CaribeShop y autorización para realizar pruebas.

## Configuración

En PowerShell:

```powershell
$env:BASE_URL="URL_REAL_DE_CARIBESHOP"
$env:TARGET_PATH="/"
```

## Escenario 1. Prueba de humo

```powershell
py -m locust -f .\pruebas\locustfile.py --headless -u 1 -r 1 --run-time 1m --csv .\pruebas\resultados\humo
```

## Escenario 2. Carga inicial

```powershell
py -m locust -f .\pruebas\locustfile.py --headless -u 5 -r 1 --run-time 2m --csv .\pruebas\resultados\carga_inicial
```

## Escenario 3. Carga media

```powershell
py -m locust -f .\pruebas\locustfile.py --headless -u 10 -r 2 --run-time 3m --csv .\pruebas\resultados\carga_media
```

## Escenario 4. Carga alta

```powershell
py -m locust -f .\pruebas\locustfile.py --headless -u 20 -r 2 --run-time 5m --csv .\pruebas\resultados\carga_alta
```

## Escenario 5. Prueba de estrés

```powershell
py -m locust -f .\pruebas\locustfile.py --headless -u 50 -r 5 --run-time 5m --csv .\pruebas\resultados\estres
```

## Consideraciones

- Ejecutar los escenarios únicamente contra el entorno autorizado.
- Comenzar por la prueba de humo.
- Revisar errores y tiempos de respuesta antes de aumentar usuarios.
- No utilizar httpbin.org como sustituto de CaribeShop.
- Guardar las evidencias de cada ejecución en `pruebas/resultados/`.
