
from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt

CARPETA = Path(__file__).parent / "resultados"


def generar_grafica(datos, columna, titulo, etiqueta, nombre):
    if columna not in datos.columns:
        print(f"No se encontró la columna {columna}")
        return

    plt.figure(figsize=(10, 5))
    plt.plot(datos["hora"], datos[columna], marker="o")
    plt.title(titulo)
    plt.xlabel("Hora")
    plt.ylabel(etiqueta)
    plt.xticks(rotation=45)
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(CARPETA / nombre)
    plt.close()

    print(f"Gráfica creada: {nombre}")


def procesar_archivo(archivo):
    print(f"\nProcesando: {archivo.name}")

    datos = pd.read_csv(archivo)
    datos.columns = datos.columns.str.strip()

    columnas_necesarias = [
        "Timestamp", "Name", "Requests/s", "Failures/s", "95%"
    ]

    faltantes = [
        columna for columna in columnas_necesarias
        if columna not in datos.columns
    ]

    if faltantes:
        print(f"Faltan columnas: {faltantes}")
        return

    datos["hora"] = pd.to_datetime(
        datos["Timestamp"], unit="s", errors="coerce"
    )

    datos = datos[datos["Name"] == "Aggregated"].copy()
    datos = datos.dropna(subset=["hora"])

    if datos.empty:
        print("No hay registros agregados para graficar.")
        return

    for columna in ["Requests/s", "Failures/s", "95%"]:
        datos[columna] = pd.to_numeric(
            datos[columna], errors="coerce"
        ).fillna(0)

    solicitudes = datos["Requests/s"]
    errores = datos["Failures/s"]

    datos["error_percent"] = (
        errores.div(solicitudes.where(solicitudes > 0)) * 100
    ).fillna(0)

    nombre_base = archivo.name.replace("_stats_history.csv", "")

    generar_grafica(
        datos,
        "Requests/s",
        f"Solicitudes por segundo - {nombre_base}",
        "Solicitudes/segundo",
        f"{nombre_base}_rps.png"
    )

    generar_grafica(
        datos,
        "95%",
        f"Tiempo de respuesta P95 - {nombre_base}",
        "Milisegundos",
        f"{nombre_base}_p95.png"
    )

    generar_grafica(
        datos,
        "error_percent",
        f"Porcentaje de errores - {nombre_base}",
        "Errores (%)",
        f"{nombre_base}_errores.png"
    )


def main():
    archivos = list(CARPETA.glob("*_stats_history.csv"))

    if not archivos:
        print("No se encontraron archivos históricos de Locust.")
        return

    for archivo in archivos:
        procesar_archivo(archivo)

    print("\nProceso de generación de gráficas terminado.")


if __name__ == "__main__":
    main()
