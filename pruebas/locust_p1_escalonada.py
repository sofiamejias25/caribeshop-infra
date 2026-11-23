"""P1.2 - Perfil escalonado (subida, sostenida, bajada) de 31 minutos para provocar scale-out y scale-in."""
import os
from locust import FastHttpUser, task, between, LoadTestShape


class Cliente(FastHttpUser):
    wait_time = between(0.0, 0.2)

    @task
    def inicio(self):
        self.client.get("/", name="/")


class Escalonada(LoadTestShape):
    pico = int(os.getenv("PICO", "150"))   # usuarios en el pico (se ajusta con P1.1)
    bajo = int(os.getenv("BAJO", "10"))    # usuarios en la bajada

    # (fin de la etapa en segundos, usuarios, velocidad de creación por segundo)
    def etapas(self):
        return [
            (300,  self.pico, max(self.pico / 300, 1)),  # 0-5 min: subida
            (1200, self.pico, 10),                       # 5-20 min: carga sostenida
            (1860, self.bajo, 10),                       # 20-31 min: bajada (scale-in)
        ]

    def tick(self):
        t = self.get_run_time()
        for fin, usuarios, velocidad in self.etapas():
            if t < fin:
                return (usuarios, velocidad)
        return None