"""CaribeShop - app mínima para el taller integrador.

Rutas:
  /         -> saludo + nombre de la instancia que respondió
  /health   -> 200 si está sana, 503 si existe el archivo bandera
  /secreto  -> lee un secreto de Key Vault con la identidad administrada
               y muestra SOLO su longitud y un hash truncado (nunca el valor)

Solo usa la librería estándar de Python.
"""
import hashlib
import json
import os
import socket
import urllib.error
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

PUERTO = int(os.environ.get("PORT", "80"))
KV_URI = os.environ.get("KEY_VAULT_URI", "").rstrip("/")   # ej. https://cs-kv-xxxx.vault.azure.net
SECRETO = os.environ.get("SECRET_NAME", "db-password")
BANDERA = os.environ.get("HEALTH_FLAG", "/var/lib/caribeshop/unhealthy")
INSTANCIA = socket.gethostname()

IMDS_TOKEN = (
    "http://169.254.169.254/metadata/identity/oauth2/token"
    "?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net"
)


def leer_secreto():
    """Pide un token a IMDS y con él lee el secreto del Key Vault."""
    if not KV_URI:
        raise RuntimeError("KEY_VAULT_URI no está configurado")

    # 1. Token de la identidad administrada (solo funciona dentro de Azure)
    req = urllib.request.Request(IMDS_TOKEN, headers={"Metadata": "true"})
    with urllib.request.urlopen(req, timeout=3) as r:
        token = json.load(r)["access_token"]

    # 2. Lectura del secreto en Key Vault
    url = f"{KV_URI}/secrets/{SECRETO}?api-version=7.4"
    req = urllib.request.Request(url, headers={"Authorization": f"Bearer {token}"})
    with urllib.request.urlopen(req, timeout=5) as r:
        return json.load(r)["value"]


class Manejador(BaseHTTPRequestHandler):
    def responder(self, codigo, cuerpo):
        datos = json.dumps(cuerpo, ensure_ascii=False).encode("utf-8")
        self.send_response(codigo)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(datos)))
        self.end_headers()
        self.wfile.write(datos)

    def do_GET(self):
        if self.path == "/":
            self.responder(200, {"mensaje": "Hola desde CaribeShop", "instancia": INSTANCIA})

        elif self.path == "/health":
            if os.path.exists(BANDERA):
                self.responder(503, {"estado": "no sana", "instancia": INSTANCIA})
            else:
                self.responder(200, {"estado": "ok", "instancia": INSTANCIA})

        elif self.path == "/secreto":
            try:
                valor = leer_secreto()
                huella = hashlib.sha256(valor.encode("utf-8")).hexdigest()[:12]
                self.responder(200, {
                    "secreto": SECRETO,
                    "longitud": len(valor),
                    "sha256_truncado": huella,
                    "instancia": INSTANCIA,
                })
            except Exception as e:  # nunca se incluye el valor en el error
                self.responder(503, {"error": type(e).__name__, "detalle": str(e)[:200]})

        else:
            self.responder(404, {"error": "ruta no encontrada"})

    def log_message(self, formato, *args):
        # Log corto: solo método, ruta y código (sin datos sensibles)
        print(f"{self.address_string()} {formato % args}", flush=True)


if __name__ == "__main__":
    print(f"CaribeShop escuchando en el puerto {PUERTO} (instancia {INSTANCIA})", flush=True)
    ThreadingHTTPServer(("0.0.0.0", PUERTO), Manejador).serve_forever()