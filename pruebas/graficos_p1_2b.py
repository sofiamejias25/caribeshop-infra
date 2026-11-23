from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

BASE = Path(__file__).resolve().parent.parent
ENTRADA = BASE / "evidencias" / "P1_2b_stats_history.csv"
SALIDA = BASE / "evidencias"

EVENTOS = [
    ("2026-11-23 05:52:06", "Scale-out: 2 a 3 instancias"),
    ("2026-11-23 06:03:35", "Scale-in: 3 a 2 instancias"),
]


def main():
    datos = pd.read_csv(ENTRADA)
    datos.columns = datos.columns.str.strip()

    datos = datos[datos["Name"].astype(str).str.strip() == "Aggregated"].copy()

    datos["hora"] = pd.to_datetime(
        datos["Timestamp"], unit="s", utc=True, errors="coerce"
    )

    for columna in ["Requests/s", "Failures/s", "95%"]:
        datos[columna] = pd.to_numeric(datos[columna], errors="coerce")

    datos = datos.dropna(subset=["hora"]).sort_values("hora")

    if datos.empty:
        print("No hay datos agregados para graficar.")
        return

    datos["error_percent"] = (
        datos["Failures/s"] /
        datos["Requests/s"].where(datos["Requests/s"] > 0) * 100
    ).fillna(0)

    eventos = [
        (pd.Timestamp(hora, tz="UTC"), etiqueta)
        for hora, etiqueta in EVENTOS
    ]

    graficas = [
        ("Requests/s", "Solicitudes por segundo - P1.2b",
         "Solicitudes/segundo", "P1_2b_rps_azure.png"),
        ("95%", "Tiempo de respuesta P95 - P1.2b",
         "Milisegundos", "P1_2b_p95_azure.png"),
        ("error_percent", "Porcentaje de errores - P1.2b",
         "Errores (%)", "P1_2b_errores_azure.png"),
    ]

    for columna, titulo, etiqueta, archivo in graficas:
        fig, ax = plt.subplots(figsize=(14, 6))

        ax.plot(datos["hora"], datos[columna], linewidth=1.2,
                label=etiqueta)

        for momento, nombre in eventos:
            ax.axvline(momento, linestyle="--", linewidth=1.5,
                       label=nombre)

        ax.set_title(titulo)
        ax.set_xlabel("Hora UTC")
        ax.set_ylabel(etiqueta)
        ax.xaxis.set_major_formatter(mdates.DateFormatter("%H:%M:%S"))
        ax.grid(True, alpha=0.3)
        ax.legend()
        fig.autofmt_xdate()
        fig.tight_layout()
        fig.savefig(SALIDA / archivo, dpi=150)
        plt.close(fig)

        print(f"Gráfica creada: evidencias/{archivo}")

    print("Proceso terminado correctamente.")


if __name__ == "__main__":
    main()
