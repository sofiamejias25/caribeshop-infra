import argparse
import csv
import os

CARPETA = os.path.dirname(os.path.abspath(__file__))
ARCHIVO_REGISTRO = os.path.join(CARPETA, "REGISTRO_ESCENARIOS.csv")

ESCENARIOS = {
    "Prueba de humo": ("1", "1 min"),
    "Carga inicial": ("5", "2 min"),
    "Carga media": ("10", "3 min"),
    "Carga alta": ("20", "5 min"),
    "Prueba de estres": ("50", "5 min"),
}


def obtener_numero(valor):
    try:
        return float(valor or 0)
    except (ValueError, TypeError):
        return 0.0


def registrar_resultados(escenario, archivo_resultados, url):
    if escenario not in ESCENARIOS:
        print("Escenario no reconocido.")
        return

    if not os.path.exists(archivo_resultados):
        print(f"No se encontró el archivo: {archivo_resultados}")
        return

    with open(archivo_resultados, newline="", encoding="utf-8-sig") as archivo:
        filas = list(csv.DictReader(archivo))

    if not filas:
        print("El archivo de resultados está vacío.")
        return

    total = next(
        (fila for fila in filas if fila.get("Name") == "Aggregated"),
        None
    )

    if total is None:
        print("No se encontró la fila Aggregated de Locust.")
        return

    solicitudes = int(obtener_numero(total.get("Request Count")))
    errores = int(obtener_numero(total.get("Failure Count")))
    promedio = obtener_numero(total.get("Average Response Time"))
    p95 = obtener_numero(total.get("95%"))
    rps = obtener_numero(total.get("Requests/s"))
    porcentaje = errores / solicitudes * 100 if solicitudes else 0

    usuarios, duracion = ESCENARIOS[escenario]

    if os.path.exists(ARCHIVO_REGISTRO):
        with open(ARCHIVO_REGISTRO, newline="", encoding="utf-8-sig") as archivo:
            registros = list(csv.DictReader(archivo))
    else:
        registros = []

    columnas = [
        "Escenario", "Usuarios", "Duracion", "URL",
        "Total_solicitudes", "RPS", "Tiempo_promedio_ms",
        "P95_ms", "Errores", "Porcentaje_errores", "Estado"
    ]

    encontrado = False

    for registro in registros:
        if registro.get("Escenario") == escenario:
            registro.update({
                "Usuarios": usuarios,
                "Duracion": duracion,
                "URL": url,
                "Total_solicitudes": solicitudes,
                "RPS": round(rps, 2),
                "Tiempo_promedio_ms": round(promedio, 2),
                "P95_ms": round(p95, 2),
                "Errores": errores,
                "Porcentaje_errores": round(porcentaje, 2),
                "Estado": "Registrado"
            })
            encontrado = True
            break

    if not encontrado:
        registros.append({
            "Escenario": escenario,
            "Usuarios": usuarios,
            "Duracion": duracion,
            "URL": url,
            "Total_solicitudes": solicitudes,
            "RPS": round(rps, 2),
            "Tiempo_promedio_ms": round(promedio, 2),
            "P95_ms": round(p95, 2),
            "Errores": errores,
            "Porcentaje_errores": round(porcentaje, 2),
            "Estado": "Registrado"
        })

    with open(ARCHIVO_REGISTRO, "w", newline="", encoding="utf-8-sig") as archivo:
        escritor = csv.DictWriter(archivo, fieldnames=columnas)
        escritor.writeheader()
        escritor.writerows(registros)

    print(f"\nEscenario registrado: {escenario}")
    print(f"Solicitudes: {solicitudes}")
    print(f"Errores: {errores}")
    print(f"Promedio: {promedio:.2f} ms")
    print(f"P95: {p95:.2f} ms")
    print(f"RPS: {rps:.2f}")
    print(f"Porcentaje de errores: {porcentaje:.2f}%")
    print("Registro actualizado correctamente.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Registra los resultados de un escenario de Locust."
    )
    parser.add_argument("--escenario", required=True, choices=ESCENARIOS.keys())
    parser.add_argument("--archivo", required=True)
    parser.add_argument("--url", default=os.getenv("BASE_URL", "Pendiente"))

    argumentos = parser.parse_args()

    registrar_resultados(
        argumentos.escenario,
        argumentos.archivo,
        argumentos.url
    )
