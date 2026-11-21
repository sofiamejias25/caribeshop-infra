
import os
from locust import HttpUser, task, between


# Dirección de la aplicación.
# Se configura al ejecutar Locust.
BASE_URL = os.getenv("BASE_URL", "http://localhost:8000")

# Ruta que se probará. Por defecto, la página principal.
TARGET_PATH = os.getenv("TARGET_PATH", "/")


class CaribeShopUser(HttpUser):
    host = BASE_URL
    wait_time = between(1, 3)

    @task
    def consultar_aplicacion(self):
        self.client.get(
            TARGET_PATH,
            name="Consulta principal"
        )
