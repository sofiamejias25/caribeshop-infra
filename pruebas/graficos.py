
from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt

CARPETA = Path(__file__).parent / "resultados"
ARCHIVO = CARPETA / "locust_stats_history.csv"


def generar_grafica(datos, columna, titulo, etiqueta, nombre):
    if columna not in datos.columns:
        print(f"No se encontró la columna {columna}")
        return

    plt.figure(figsize=(10, 5))
    plt.plot(datos["hora"], datos[columna])
    plt.title(titulo)
    plt.xlabel("Hora")
    plt.ylabel(etiqueta)
    plt.xticks(rotation=45)
    plt.grid(True)
    plt.tight_layout()
    plt.savefig(CARPETA / nombre)
    plt.close()

    print(f"Gráfica creada: {nombre}")


def main():
    if not ARCHIVO.exists():
        print("No existe el archivo de resultados de Locust.")
        return

    datos = pd.read_csv(ARCHIVO)

    # Normalizar nombres de columnas
    datos.columns = datos.columns.str.strip()

    # Convertir Timestamp (Unix) a fecha
    datos["hora"] = pd.to_datetime(
        datos["Timestamp"], unit="s", errors="coerce"
    )

    # Utilizar únicamente los registros agregados
    datos = datos[datos["Name"] == "Aggregated"].copy()
    datos = datos.dropna(subset=["hora"])

    if datos.empty:
        print("No hay registros agregados para graficar.")
        return

    # Gráfica de solicitudes por segundo
    generar_grafica(
        datos, "Requests/s",
        "Solicitudes por segundo (RPS)",
        "Solicitudes/segundo", "rps.png"
    )

    # Gráfica de tiempo de respuesta p95
    datos["95%"] = pd.to_numeric(datos["95%"], errors="coerce")

    generar_grafica(
        datos, "95%",
        "Tiempo de respuesta percentil 95 (p95)",
        "Milisegundos", "p95.png"
    )

    # Calcular porcentaje de errores
    solicitudes = pd.to_numeric(
        datos["Requests/s"], errors="coerce"
    ).fillna(0)

    errores = pd.to_numeric(
        datos["Failures/s"], errors="coerce"
    ).fillna(0)

    datos["error_percent"] = (
        errores.div(solicitudes.where(solicitudes > 0)) * 100
    ).fillna(0)

    generar_grafica(
        datos, "error_percent",
        "Porcentaje de errores",
        "Errores (%)", "errores.png"
    )

    print("\nGráficas generadas correctamente.")


if __name__ == "__main__":
    main()
