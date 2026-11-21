
import csv
import os

CARPETA = os.path.dirname(os.path.abspath(__file__))
ARCHIVO_REGISTRO = os.path.join(CARPETA, "REGISTRO_ESCENARIOS.csv")
ARCHIVO_RESULTADOS = os.path.join(CARPETA, "resultados", "locust_stats.csv")


def registrar_resultados():
    if not os.path.exists(ARCHIVO_RESULTADOS):
        print("No se encontró el archivo de resultados de Locust.")
        return

    with open(ARCHIVO_RESULTADOS, newline="", encoding="utf-8-sig") as archivo:
        filas = list(csv.DictReader(archivo))

    if not filas:
        print("El archivo de resultados está vacío.")
        return

    total = next(
        (fila for fila in filas if fila.get("Name") == "Aggregated"),
        filas[-1]
    )

    solicitudes = int(total.get("Request Count") or 0)
    errores = int(total.get("Failure Count") or 0)
    promedio = float(total.get("Average Response Time") or 0)
    p95 = float(total.get("95%") or 0)
    rps = float(total.get("Requests/s") or 0)
    porcentaje = errores / solicitudes * 100 if solicitudes else 0

    print("\nResultados encontrados:")
    print(f"Solicitudes: {solicitudes}")
    print(f"Errores: {errores}")
    print(f"Promedio: {promedio:.2f} ms")
    print(f"P95: {p95:.2f} ms")
    print(f"RPS: {rps:.2f}")
    print(f"Porcentaje de errores: {porcentaje:.2f}%")

    print("\nEstos datos corresponden al último archivo CSV.")
    print("Verifica el escenario y la URL antes de registrarlos.")


if __name__ == "__main__":
    registrar_resultados()
