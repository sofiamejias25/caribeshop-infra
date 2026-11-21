
import os
from locust import HttpUser, task, between

BASE_URL = os.getenv("BASE_URL", "http://localhost:8000")
TARGET_PATH = os.getenv("TARGET_PATH", "/")


class CaribeShopUser(HttpUser):
    host = BASE_URL
    wait_time = between(1, 3)

    @task
    def consultar_aplicacion(self):
        with self.client.get(
            TARGET_PATH,
            name="Consulta principal",
            catch_response=True
        ) as response:

            if response.status_code >= 400:
                response.failure(
                    f"Error HTTP {response.status_code}"
                )
