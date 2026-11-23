"""P1.1 - Capacidad de una instancia: usuarios en escalones hasta que el p95 supere 1 s."""
import os
from locust import FastHttpUser, task, between, LoadTestShape


class Cliente(FastHttpUser):
    wait_time = between(0.0, 0.2)

    @task
    def inicio(self):
        self.client.get("/", name="/")


class Escalones(LoadTestShape):
    paso = int(os.getenv("PASO", "20"))          # usuarios que se suman en cada escalón
    paso_seg = int(os.getenv("PASO_SEG", "45"))  # duración de cada escalón (s)
    maximo = int(os.getenv("MAX", "300"))        # tope de usuarios

    def tick(self):
        t = self.get_run_time()
        usuarios = (int(t // self.paso_seg) + 1) * self.paso
        if usuarios > self.maximo:
            return None  # fin de la prueba
        return (usuarios, self.paso)